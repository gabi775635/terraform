# TP Terraform 2 — Infrastructure AWS

Déploiement d'une infrastructure AWS avec Terraform : VPC, subnets, Internet Gateway, Security Group et instance EC2 Ubuntu avec Nginx.

---

## Prérequis

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.7.0
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configuré
- Une Key Pair AWS existante dans la région `us-east-1`
- Un compte GitHub avec un Personal Access Token

---

## Structure du projet
tp2/
├── main.tf                 # Ressources AWS (VPC, subnets, EC2…)
├── providers.tf            # Configuration du provider AWS
├── variables.tf            # Déclaration des variables
├── outputs.tf              # Sorties (IP publique, URL HTTP)
├── terraform.tfvars        # Valeurs des variables (non commité)
├── user-data.sh            # Script de démarrage EC2 (installation Nginx)
├── .terraform.lock.hcl     # Verrouillage des versions providers (commité)
└── .gitignore              # Fichiers exclus du dépôt

---

## Infrastructure déployée

Internet
│
▼
Internet Gateway
│
▼
VPC (10.10.0.0/16)
├── Subnet public  (10.10.1.0/24) — us-east-1a
│       └── EC2 t3.micro (Ubuntu 22.04 + Nginx)
└── Subnet privé   (10.10.2.0/24) — us-east-1a


---

## Variables

| Variable | Description | Défaut |
|---|---|---|
| `student_name` | Prénom de l'étudiant | `gabriel` |
| `promo_name` | Nom de la promo | `EADL-2026` |
| `environment` | Environnement | `dev` |
| `region` | Région AWS | `us-east-1` |
| `vpc_cidr` | CIDR du VPC | `10.10.0.0/16` |
| `public_subnet_cidr` | CIDR subnet public | `10.10.1.0/24` |
| `private_subnet_cidr` | CIDR subnet privé | `10.10.2.0/24` |
| `key_pair_name` | Nom de la Key Pair AWS | *(obligatoire)* |

---

## Utilisation

### 1. Cloner le dépôt

```bash
git clone https://github.com/gabi775635/terraform.git
cd terraform
```

### 2. Créer le fichier de variables

```bash
cat > terraform.tfvars <<EOF
key_pair_name = "tf-gabriel-dev-key"
EOF
```

### 3. Initialiser Terraform

```bash
terraform init
```

### 4. Vérifier le plan

```bash
terraform plan
```

### 5. Déployer

```bash
terraform apply
```

### 6. Récupérer l'URL de l'instance

```bash
terraform output web_url
```

### 7. Tester Nginx

```bash
curl $(terraform output -raw web_url)
```

### 8. Se connecter en SSH

```bash
ssh -i ~/.ssh/tf-gabriel-dev-key ubuntu@$(terraform output -raw instance_public_ip)
```

### 9. Détruire l'infrastructure

```bash
terraform destroy
```

---

## Tags appliqués aux ressources

| Tag | Valeur | Source |
|---|---|---|
| `StudentName` | `gabriel` | `default_tags` provider |
| `PromoName` | `EADL-2026` | `default_tags` provider |
| `course` | `TF-2026-02` | `locals` |
| `env` | `dev` | `locals` |
| `managed` | `terraform` | `locals` |
| `owner` | `gabriel` | `locals` |
| `Name` | *(par ressource)* | chaque ressource |

---

## Auteur

**Gabriel** — Promo EADL-2026  
Cours TF-2026-02
