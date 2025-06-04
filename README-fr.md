# 🔐 Démo AWS – Identité & Permissions : « Pas touche à mon bucket ! »

![Paws Off My Bucket](resources/paws-off-my-bucket.png)

## 🎯 Objectif de la démo

Cette démonstration pratique vous présente le contrôle d'accès dans **Amazon S3** à l'aide des **politiques de bucket** et des **politiques IAM**, y compris :

* La différence entre **politiques IAM** et **politiques de bucket**
* Comment une instruction **`Deny` explicite** prévaut sur toute autorisation `Allow`
* Le **principe du moindre privilège**
* Le contrôle d'accès basé sur **l'adresse IP** et **l'identité du rôle IAM**

Conçue pour tous les niveaux : débutants, intermédiaires et avancés.

---

## 📈 Prérequis

Vous devez disposer d’un **utilisateur ou rôle IAM** avec les autorisations suivantes :

* Créer un bucket S3
* Attacher une politique à un bucket
* Créer des rôles et des politiques IAM
* Assumer des rôles
* Utiliser AWS CloudShell ou AWS CLI localement
* Déployer des stacks CloudFormation

---

## 📋 Vue d'ensemble des rôles IAM

| Nom du rôle IAM                  | Accès au bucket S3 | Remarques                             |
| -------------------------------- | ------------------ | ------------------------------------- |
| DemoNoS3PermissionsRole          | ❌ Aucun            | Aucun accès à S3                      |
| DemoS3AccessGrantedRole          | ✅ Autorisé         | Autorisation explicite `s3:GetObject` |
| DemoDuplicateS3AccessGrantedRole | ✅ Autorisé         | Identique au précédent                |
| DemoS3AccessDeniedRole           | ⛔ Refusé           | Refus explicite sur `s3:GetObject`    |

---

## 🧱 Instructions

### 📓 1. Créer un bucket de test

#### Option A : En utilisant AWS CLI

```bash
aws s3api create-bucket --bucket <VOTRE_BUCKET> --region <VOTRE_RÉGION>
```

#### Option B : Via la console AWS

1. Accédez à la [console S3](https://s3.console.aws.amazon.com/s3/home)
2. Cliquez sur **Create bucket**
3. Entrez un nom de bucket globalement unique (ex : `demo-bucket-nom-unique`)
4. Choisissez une région
5. Laissez les autres paramètres par défaut ou adaptez-les
6. Cliquez sur **Create bucket**

### 📂 2. Téléverser un fichier test

#### Option A : AWS CLI

```bash
aws s3 cp resources/paws-off-my-bucket.png s3://<VOTRE_BUCKET>/
```

#### Option B : Console AWS

1. Accédez à votre bucket
2. Cliquez sur **Upload**
3. Ajoutez `paws-off-my-bucket.png`
4. Cliquez sur **Upload**

### 📄 3. Créer les rôles IAM

#### Option A : Création manuelle via la console AWS

Accédez à la [console IAM](https://console.aws.amazon.com/iam/home)

##### Créer la politique **Allow s3:GetObject**

1. Dans le menu de gauche, sous **Access Management**, cliquez sur **Policies**
2. Cliquez sur **Create policy**
3. Dans **Specify permissions**, passez en mode **JSON**
4. Collez la politique suivante :
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowS3GetObject",
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": [
        "arn:aws:s3:::<VOTRE_BUCKET>",
        "arn:aws:s3:::<VOTRE_BUCKET>/*"
      ]
    }
  ]
}
```
5. Cliquez sur **Next**
6. Donnez un nom à la politique, par exemple **DemoS3BucketAllowGetObjectPermission**
7. Cliquez sur **Create policy**

##### Créer la politique **Deny s3:GetObject**

Répétez les étapes précédentes en changeant simplement le `Effect` de `Allow` à `Deny` :
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyS3GetObject",
      "Effect": "Deny",
      "Action": "s3:GetObject",
      "Resource": [
        "arn:aws:s3:::<VOTRE_BUCKET>",
        "arn:aws:s3:::<VOTRE_BUCKET>/*"
      ]
    }
  ]
}
```
Nommez cette politique : **DemoS3BucketDenyGetObjectPermission**

##### Créer les rôles pour la démonstration

1. Dans le menu de gauche, cliquez sur **Roles**
2. Cliquez sur **Create role**
3. Sélectionnez **AWS Account** comme type d'entité de confiance
4. Choisissez **This account** (votre propre compte)
5. Cliquez sur **Next**
6. Sélectionnez les autorisations adéquates :
   - **Aucune politique**
   - **DemoS3BucketAllowGetObjectPermission**
   - **DemoS3BucketDenyGetObjectPermission**
7. Cliquez sur **Next**, donnez un nom au rôle
8. Cliquez sur **Create role**

En appliquant les étapes précédentes, créez 4 rôles IAM en leur associant les permissions appropriées :

* `DemoNoS3PermissionsRole` : **Aucune politique**
* `DemoS3AccessGrantedRole` : **DemoS3BucketAllowGetObjectPermission**
* `DemoDuplicateS3AccessGrantedRole` : **DemoS3BucketAllowGetObjectPermission**
* `DemoS3AccessDeniedRole` : **DemoS3BucketDenyGetObjectPermission**

#### Option B : Avec CloudFormation

```bash
aws cloudformation deploy \
  --template-file ./iam-roles-template.yaml \
  --stack-name identity-permissions-demo \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides BucketName=VOTRE_BUCKET Environment=demo
```

#### Option C : Avec Terraform

```bash
cd terraform
terraform init
terraform apply \
  -var="bucket_name=VOTRE_BUCKET" \
  -var="environment=demo"
```

### 🚨 4. Autoriser votre utilisateur à assumer les rôles

Attachez cette politique à votre utilisateur IAM :

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": [
        "arn:aws:iam::<ID_COMPTE>:role/DemoNoS3PermissionsRole",
        "arn:aws:iam::<ID_COMPTE>:role/DemoS3AccessGrantedRole",
        "arn:aws:iam::<ID_COMPTE>:role/DemoDuplicateS3AccessGrantedRole",
        "arn:aws:iam::<ID_COMPTE>:role/DemoS3AccessDeniedRole"
      ]
    }
  ]
}
```

### 👷 5. Comment assumer un rôle

#### Option A : En ligne de commande

```bash
aws sts assume-role \
  --role-arn arn:aws:iam::<ID_COMPTE>:role/DemoS3AccessGrantedRole \
  --role-session-name demo-session
```

Puis exportez les identifiants temporaires :

```bash
export AWS_ACCESS_KEY_ID=<clé>
export AWS_SECRET_ACCESS_KEY=<secret>
export AWS_SESSION_TOKEN=<token>
```

#### Option B : Via la console AWS

1. Accédez à la console IAM
2. Recherchez le rôle
3. Cliquez sur **Switch role** ou utilisez le menu déroulant en haut à droite

---

### 👷 6. Comment mettre en place une bucket policy

Vous pouvez le faire de deux manières:

#### Option A: AWS CLI

* Créer fichier json contenant votre bucket policy
* Effectuer une requête API `put-bucket-policy` :

```bash
aws s3api put-bucket-policy \
  --bucket <YOUR_TEST_BUCKET_NAME> \
  --policy file://path/to/your/<POLICY_FILE>.json
```

#### Option B: AWS Console

1. Aller sur [la console S3](https://s3.console.aws.amazon.com/s3/home)
2. Ouvrir votre bucket en cliquant sur son nom
3. Aller sur l'onglet **Permissions**
4. Cliquer **Modifier** sur la partie `Bucket policy`
5. Coller le code de votre bucket policy
6. Cliquer sur **Enregistrer**
```

---

### 🔎 6. Tester l’accès à l’objet

#### AWS CLI

```bash
aws s3api get-object \
  --bucket <VOTRE_BUCKET> \
  --key paws-off-my-bucket.png \
  paws-test.png
```

#### Console AWS

1. Accédez au bucket
2. Sélectionnez l’objet
3. Cliquez sur **Download**

#### Navigateur

```
https://<VOTRE_BUCKET>.s3.<RÉGION>.amazonaws.com/paws-off-my-bucket.png
```

💡 **Astuce :** Si vous obtenez une erreur `AccessDenied` :

* Vérifiez le rôle utilisé
* Assurez-vous que la politique est bien appliquée
* Vérifiez l'absence de `Deny` dans des SCP (Service Control Policy)

---

## 🧪 Scénarios à tester

### ✅ 1. `Allow` depuis une IP spécifique uniquement

Appliquez la politique suivante au bucket, en remplaçant les placeholders :

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

* Test : téléchargement via un navigateur : [https://YOUR-BUCKET-NAME.s3.AWS-REGION.amazonaws.com/YOUR-OBJECT-NAME](https://YOUR-BUCKET-NAME.s3.AWS-REGION.amazonaws.com/YOUR-OBJECT-NAME)

* Résultats attendus :

  * Accès depuis l'IP autorisée → Succès
  * Accès depuis toute autre IP → Refusé

### ❌ 2. `Deny` sauf depuis une IP spécifique

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

* Test :

  * Mauvaise IP + **DemoS3AccessGrantedRole** → Refusé
  * Mauvaise IP + **DemoS3AccessDeniedRole** → Refusé
  * Bonne IP + **DemoNoS3PermissionsRole** → Refusé
  * Bonne IP + **DemoS3AccessGrantedRole** → Succès

### ✅ 3. `Allow` pour un rôle IAM spécifique

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

* Test :

  * Accès avec **DemoNoS3PermissionsRole** → Succès
  * Accès avec **DemoS3AccessGrantedRole** → Succès
  * Accès avec **DemoS3AccessDeniedRole** → Refusé

### ❌ 4. `Deny` sauf si usage d'un rôle IAM spécifique

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

* Test :

  * Accès avec **DemoNoS3PermissionsRole** → Refusé
  * Accès avec **DemoS3AccessDeniedRole** → Refusé
  * Accès avec **DemoDuplicateS3AccessGrantedRole** → Refusé
  * Accès avec **DemoS3AccessGrantedRole** → Succès

---

## 🧹 Nettoyage

⚠️ **Attention :** Ne supprimez pas accidentellement un bucket contenant des données sensibles !

* Retirez la politique `AssumeRole` de l’utilisateur IAM
* Supprimez les rôles et politiques créés :

  * Via la console IAM
  * Via CloudFormation :

```bash
aws cloudformation delete-stack --stack-name identity-permissions-demo
```

* Via Terraform :

```bash
terraform destroy -var="bucket_name=VOTRE_BUCKET" -var="environment=demo"
```

* Supprimez le bucket :

```bash
aws s3 rm s3://<VOTRE_BUCKET> --recursive
aws s3api delete-bucket-policy --bucket <VOTRE_BUCKET>
aws s3api delete-bucket --bucket <VOTRE_BUCKET>
```

---

Cette démo est idéale pour comprendre l'interaction entre IAM et les politiques de bucket S3, expérimenter la logique `Deny`, et renforcer les principes de moindre privilège.
