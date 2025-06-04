# 🔐 AWS Demo – Identity & Permissions: "Hands off my bucket!"

![Paws Off My Bucket](resources/paws-off-my-bucket.png)

## 🎯 Demo Objective

This hands-on demo introduces access control in **Amazon S3** using **Bucket Policies** and **IAM**, including:

* The difference between **IAM Policies** and **Bucket Policies**
* How **explicit `Deny` overrides** any `Allow`
* The **least privilege principle**
* Access control using **IP address** and **IAM Role identity**

Designed for all skill levels: beginners, intermediates, and advanced learners.

---

## 📈 Prerequisites

You need an IAM **user or role** with permission to:

* Create an S3 bucket
* Attach a bucket policy
* Create IAM roles and policies
* Assume roles
* Use AWS CloudShell or local AWS CLI
* Deploy CloudFormation stacks

---

## 📋 IAM Role Overview

| IAM Role Name                  | Access to S3 Bucket | Notes                          |
|------------------------------|---------------------|--------------------------------|
| DemoNoS3PermissionsRole      | ❌ None             | Role with no S3 permissions    |
| DemoS3AccessGrantedRole      | ✅ Allowed          | Has `s3:GetObject` permission  |
| DemoDuplicateS3AccessGrantedRole | ✅ Allowed     | Same as above                 |
| DemoS3AccessDeniedRole       | ⛔ Denied           | Explicit `Deny` for GetObject |

---

## 🧱 Instructions

### 📓 1. Create your test bucket

You can do this in two ways:

#### Option A: Using AWS CLI

```bash
aws s3api create-bucket --bucket <YOUR_TEST_BUCKET_NAME> --region <YOUR_REGION>
```

#### Option B: Using the AWS Console

1. Go to the [S3 Console](https://s3.console.aws.amazon.com/s3/home)
2. Click **Create bucket**
3. Enter a globally unique bucket name (e.g., `demo-bucket-unique-id`)
4. Select your preferred region
5. Leave all other settings as default, or adjust as needed
6. Click **Create bucket**

### 📂 2. Upload a test file

You can do this in two ways:

#### Option A: Using AWS CLI

```bash
aws s3 cp resources/paws-off-my-bucket.png s3://<YOUR_TEST_BUCKET_NAME>/
```

#### Option B: Using the AWS Console

1. Go to the [S3 Console](https://s3.console.aws.amazon.com/s3/home)
2. Open your bucket by clicking its name
3. Click **Upload**
4. Choose **Add files** and select `paws-off-my-bucket.png`
5. Click **Upload** at the bottom

### 📄 3. Create IAM roles

You will create 4 roles:

#### Option A: Manually using AWS Console

Go to the [IAM Console](https://console.aws.amazon.com/iam/home)

##### Create the permission Allow s3:GetObject for your bucket

1. On the left menu, under `Access Management` click on `Policies`
2. Click on `Create policy`
3. On `Specify permissions` toggle to `JSON`
4. Paste the following
```json
{
  "Version": "2012-10-17",
  "Statement": [
      {
        "Sid": "AllowS3GetObject",
        "Effect": "Allow",
        "Action": "s3:GetObject",
        "Resource": [
            "arn:aws:s3:::<YOUR_TEST_BUCKET_NAME>",
            "arn:aws:s3:::<YOUR_TEST_BUCKET_NAME>/*"
        ]
      }
  ]
}
```
5. Click `Next`
6. Add name **DemoS3BucketAllowGetObjectPermission**
7. Click on `Create policy`

##### Create the permission Deny s3:GetObject for your bucket

* Repeat the same steps to create a new policy **DemoS3BucketDenyGetObjectPermission** using this code:
```json
{
  "Version": "2012-10-17",
  "Statement": [
      {
        "Sid": "DenyS3GetObject",
        "Effect": "Deny",
        "Action": "s3:GetObject",
        "Resource": [
            "arn:aws:s3:::<YOUR_TEST_BUCKET_NAME>",
            "arn:aws:s3:::<YOUR_TEST_BUCKET_NAME>/*"
        ]
      }
  ]
}
```

##### Create the roles for the demo

1. On the left menu, under `Access Management` click on `Roles`
2. Click on `Create role`
3. On `Select trusted entity` screen, choose `AWS Account`, 
4. Then choose your AWS account
5. Click `Next`
6. Choose the appropriate permissions: 
   - **None**
   - **DemoS3BucketAllowGetObjectPermission**
   - **DemoS3BucketDenyGetObjectPermission**
7. Click `Next`
8. Define a name for the role
9. Click on `Create role`

Apply these steps for each of the following roles:

* `DemoNoS3PermissionsRole` : **Aucune politique**
* `DemoS3AccessGrantedRole` : **DemoS3BucketAllowGetObjectPermission**
* `DemoDuplicateS3AccessGrantedRole` : **DemoS3BucketAllowGetObjectPermission**
* `DemoS3AccessDeniedRole` : **DemoS3BucketDenyGetObjectPermission**

#### Option B: With CloudFormation

```bash
aws cloudformation deploy \
  --template-file .\iam-roles-template.yaml \
  --stack-name identity-permissions-demo \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides BucketName=YOUR_TEST_BUCKET_NAME Environment=demo
```

#### Option B: With Terraform

```bash
cd terraform
terraform init
terraform apply \
  -var="bucket_name=YOUR_TEST_BUCKET_NAME" \
  -var="environment=demo"
```

### 🚨 4. Allow your user to assume the roles

Attach the following policy to your IAM user:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": [
        "arn:aws:iam::<YOUR_ACCOUNT_ID>:role/DemoNoS3PermissionsRole",
        "arn:aws:iam::<YOUR_ACCOUNT_ID>:role/DemoS3AccessGrantedRole",
        "arn:aws:iam::<YOUR_ACCOUNT_ID>:role/DemoDuplicateS3AccessGrantedRole",
        "arn:aws:iam::<YOUR_ACCOUNT_ID>:role/DemoS3AccessDeniedRole"
      ]
    }
  ]
}
```

### 👷 5. How to assume a role

You can do this in two ways:

#### Option A: Using AWS CLI

```bash
aws sts assume-role \
  --role-arn arn:aws:iam::<YOUR_ACCOUNT_ID>:role/DemoS3AccessGrantedRole \
  --role-session-name demo-session
```

Export the temporary credentials:

```bash
export AWS_ACCESS_KEY_ID=<value-from-output>
export AWS_SECRET_ACCESS_KEY=<value-from-output>
export AWS_SESSION_TOKEN=<value-from-output>
```

#### Option B: Using the AWS Console

1. Go to the [IAM Console](https://console.aws.amazon.com/iam/home#/roles)
2. Search for the role you want to assume (e.g., `DemoS3AccessGrantedRole`)
3. Click on the role name
4. In the **Role ARN** section, click **Switch Role** link (if available) and paste it in a browser tab, or use the drop-down menu under your username (top-right) → **Switch Role**
5. Enter the Account ID and Role name, choose a Display Name and optional color, then click **Switch Role**

You are now using that role in the Console — try accessing S3 via the Console interface to test access!

### 👷 6. How to put a bucket policy

You can do this in two ways:

#### Option A: Using AWS CLI

* Create a json file containing your policy
* Call `put-bucket-policy` API request:

```bash
aws s3api put-bucket-policy \
  --bucket <YOUR_TEST_BUCKET_NAME> \
  --policy file://path/to/your/<POLICY_FILE>.json
```

#### Option B: Using AWS Console

1. Go to the [S3 Console](https://s3.console.aws.amazon.com/s3/home)
2. Open your bucket by clicking its name
3. Go to tab **Permissions**
4. Click **Edit** under `Bucket policy`
5. Paste your policy
6. Click **Save** at the bottom
```

---

### 🔎 7. How to test object access

Using AWS CLI:

```bash
aws s3api get-object \
  --bucket <YOUR_TEST_BUCKET_NAME> \
  --key paws-off-my-bucket.png \
  paws-test.png
```

Using AWS Console:

1. Go to S3
2. Click on your bucket
3. On tab `Objects`, choose your test object paws-off-my-bucket.png
4. Click on `Download` button

Using browser:

```
https://<YOUR_TEST_BUCKET_NAME>.s3.<REGION>.amazonaws.com/paws-off-my-bucket.png
```

Expected result: file downloads if allowed, otherwise AccessDenied error.

💡 **Troubleshooting tip**: If you're unexpectedly getting `AccessDenied`, verify that:
- You are using the correct IAM role (check current identity)
- Your bucket policy was correctly applied
- There are no conflicting `Deny` rules from other layers (SCP, Service Control Policy)

---

## 🧪 Scenarios to Test

### ✅ 1. `Allow` from a specific IP

**Replace placeholders with appropriate values.** and apply the following policy to your bucket
```json
{
  "Version": "2012-10-17",
  "Statement": [
      {
        "Sid": "AllowFromSpecificIP",
        "Effect": "Allow",
        "Principal": "*",
        "Action": "s3:GetObject",
        "Resource": [
            "arn:aws:s3:::<YOUR_TEST_BUCKET_NAME>",
            "arn:aws:s3:::<YOUR_TEST_BUCKET_NAME>/*"
        ],
        "Condition": {
            "IpAddress": {
                "aws:SourceIp": "<YOUR_TEST_IP>/32"
            }
        }
      }
  ]
}
```

* Test: download from a browser using this link: https://YOUR-BUCKET-NAME.s3.AWS-REGION.amazonaws.com/YOUR-OBJECT-NAME

* Expected results:
  * Access from allowed IP → Success
  * Access from any other IP → Denied

### ❌ 2. `Deny` unless from a specific IP

**Replace placeholders with appropriate values.** and apply the following policy to your bucket
```json
{
  "Version": "2012-10-17",
  "Statement": [
      {
        "Sid": "DenyUnlessFromSpecificIP",
        "Effect": "Deny",
        "Principal": "*",
        "Action": "s3:GetObject",
        "Resource": [
            "arn:aws:s3:::<YOUR_TEST_BUCKET_NAME>",
            "arn:aws:s3:::<YOUR_TEST_BUCKET_NAME>/*"
        ],
        "Condition": {
            "NotIpAddress": {
                "aws:SourceIp": "<YOUR_TEST_IP>/32"
            }
        }
      }
  ]
}
```

* Test:

  * Wrong IP + **DemoS3AccessGrantedRole** → Denied
  * Wrong IP + **DemoS3AccessDeniedRole** → Denied
  * Wrong IP + **DemoS3AccessGrantedRole** → Denied
  * Correct IP + **DemoNoS3PermissionsRole** → Denied
  * Correct IP + **DemoS3AccessDeniedRole** → Denied
  * Correct IP  + **DemoS3AccessGrantedRole** → Success

### ✅ 3. `Allow` to a specific IAM role

**Replace placeholders with appropriate values.** and apply the following policy to your bucket
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSpecificRole",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::<YOUR_AWS_ACCOUNT_ID>:role/DemoNoS3PermissionsRole"
      },
      "Action": "s3:GetObject",
      "Resource": [
        "arn:aws:s3:::<YOUR_TEST_BUCKET_NAME>",
        "arn:aws:s3:::<YOUR_TEST_BUCKET_NAME>/*"
      ]
    }
  ]
}
```

* Test:

  * Access using **DemoNoS3PermissionsRole** → Success
  * Access using **DemoS3AccessGrantedRole** → Success
  * Access using **DemoS3AccessDeniedRole** → Denied

### ❌ 4. `Deny` unless using a specific IAM role

**Replace placeholders with appropriate values.** and apply the following policy to your bucket
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyUnlessSpecificRole",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": [
        "arn:aws:s3:::<YOUR_TEST_BUCKET_NAME>",
        "arn:aws:s3:::<YOUR_TEST_BUCKET_NAME>/*"
      ],
      "Condition": {
        "StringNotEquals": {
          "aws:PrincipalArn": "arn:aws:iam::<YOUR_AWS_ACCOUNT_ID>:role/DemoS3AccessGrantedRole"
        }
      }
    }
  ]
}
```

* Test: 

  * Access using **DemoNoS3PermissionsRole** → Denied
  * Access using **DemoS3AccessDeniedRole** → Denied
  * Access using **DemoDuplicateS3AccessGrantedRole** → Denied
  * Access using **DemoS3AccessGrantedRole** → Success

---

## 🧹 Cleanup

⚠️ **Warning:** If your bucket contains production or important data, do not delete it accidentally during cleanup!

* Remove the `AssumeRole` from your IAM user
* Delete the created roles and permissions depending on how you created them:
    + Manually: Go to IAM Console and delete the roles, and then the permissions
    + CloudFormation: `aws cloudformation delete-stack --stack-name identity-permissions-demo`
    + Terraform: `terraform destroy -var="bucket_name=YOUR_TEST_BUCKET_NAME" -var="environment=demo"`
* Delete the S3 bucket:  
```bash
aws s3 rm s3://<YOUR_TEST_BUCKET_NAME> --recursive
aws s3api delete-bucket-policy --bucket <YOUR_TEST_BUCKET_NAME>
aws s3api delete-bucket --bucket <YOUR_TEST_BUCKET_NAME>
```

---

This demo is ideal for understanding how IAM and S3 Bucket Policies interact, testing `Deny` logic, and enforcing least privilege.
