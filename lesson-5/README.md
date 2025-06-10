# Документація проєкту

## Опис структури проєкту

Цей проєкт реалізує базову інфраструктуру AWS за допомогою Terraform. Він включає такі модулі:

- **s3-backend** — зберігання стану Terraform
- **vpc** — створення VPC, публічних і приватних підмереж, а також налаштування маршрутів
- **ecr** — репозиторій Docker-образів у ECR

### Модуль s3-backend

S3-бакет для зберігання стану Terraform, з включеним версіонуванням та контролем власності. DynamoDB-таблиця (terraform_locks) — для запобігання одночасного застосування конфігурацій.

### Модуль vpc

Побудова ізольованої мережі, де:

- Публічні підмережі доступні напряму з інтернету. (3 штуки, по довжині `public_subnets` у `main.tf`)
- Приватні підмережі мають вихід у зовнішній світ через NAT Gateway. (3 штуки, по довжині `private_subnets` у `main.tf`)

Налаштування маршрутів для публічного і приватного трафіку:

- Публічні підмережі — прямий вихід через IGW.
- Приватні підмережі — вихід через NAT Gateway.

### Модуль ecr

ECR-репозиторій для зберігання контейнерів з автоматичним скануванням вразливостей (опція scan_on_push). Додається IAM політика для дозволу читання/завантаження образів.

## Команди для ініціалізації та запуску

```
# Ініціалізація (завантажує плагіни, налаштовує бекенд)
terraform init

# Попередній перегляд змін (план застосування)
terraform plan

# Застосування змін (створення інфраструктури)
terraform apply

# Знищення всієї інфраструктури
terraform destroy
```

## Outputs

```
aws_eip_id = "eipalloc-0b6fbb88e4c38d8ab"
aws_nat_gateway_id = "nat-03855f8cb76e614fc"
dynamodb_table_name = "terraform-locks"
internet_gateway_id = "igw-0ca8ab79f7534cb34"
private_subnets = [
  "subnet-0825d40b78deffb27",
  "subnet-05254baa162ab14ef",
  "subnet-0e9aef45421e7e44e",
]
public_subnets = [
  "subnet-0f4db970a33ed4fcc",
  "subnet-05229e85c274ae047",
  "subnet-05ce9c9f1b8c0ee44",
]
repository_arn = "arn:aws:ecr:eu-central-1:748257756796:repository/lesson-5-ecr"
repository_url = "748257756796.dkr.ecr.eu-central-1.amazonaws.com/lesson-5-ecr"
s3_bucket_name = "terraform-state-bucket-455062"
vpc_id = "vpc-0d62db58a5705b5f7"
```

## Нотатки з нюансами по запуску

Для запуску всього проєкту нам спочатку треба мати сам S3 бакет та таблицю, де зберігатиметься стейт.

Для цього коментуємо у файлі main.tf усе, що не стосується модуля s3-backend, а також — увесь backend.tf.

Після цього пишемо в терміналі `terraform init -reconfigure`, `terraform apply`.

```
module.s3_backend.aws_dynamodb_table.terraform_locks: Creating...
module.s3_backend.aws_s3_bucket.terraform_state: Creating...
module.s3_backend.aws_s3_bucket.terraform_state: Creation complete after 6s [id=terraform-state-bucket-455062]
module.s3_backend.aws_s3_bucket_ownership_controls.terraform_state_ownership: Creating...
module.s3_backend.aws_s3_bucket_versioning.terraform_state_versioning: Creating...
module.s3_backend.aws_s3_bucket_ownership_controls.terraform_state_ownership: Creation complete after 0s [id=terraform-state-bucket-455062]
module.s3_backend.aws_s3_bucket_versioning.terraform_state_versioning: Creation complete after 1s [id=terraform-state-bucket-455062]
module.s3_backend.aws_dynamodb_table.terraform_locks: Still creating... [00m10s elapsed]
module.s3_backend.aws_dynamodb_table.terraform_locks: Creation complete after 11s [id=terraform-locks]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
```

Тепер можна розкоментити `backend.tf` та весь інший вміст `main.tf` та прогнати команду `terraform init -reconfigure`.

Що змінилось з прикладу в уроці:

1. Ми створили NAT Gateway для приватних підмереж (для цього створили Elastic IP та додали маршрут для виходу в інтернет через NAT Gateway).

2. Ми створили ecr, де прописали можливість прокидувати з `main.tf` змінні та налаштували policies. Також додали `output.tf`.

```
module.ecr.aws_ecr_repository_policy.this: Creating...
module.vpc.aws_eip.nat: Creating...
module.vpc.aws_vpc.main: Creating...
module.vpc.aws_eip.nat: Creation complete after 0s [id=eipalloc-0b6fbb88e4c38d8ab]
module.vpc.aws_vpc.main: Still creating... [00m10s elapsed]
module.vpc.aws_vpc.main: Creation complete after 11s [id=vpc-0d62db58a5705b5f7]
module.vpc.aws_subnet.public[2]: Creating...
module.vpc.aws_route_table.public: Creating...
module.vpc.aws_internet_gateway.igw: Creating...
module.vpc.aws_route_table.private: Creating...
module.vpc.aws_subnet.private[1]: Creating...
module.vpc.aws_subnet.public[1]: Creating...
module.vpc.aws_subnet.private[2]: Creating...
module.vpc.aws_subnet.private[0]: Creating...
module.vpc.aws_subnet.public[0]: Creating...
module.vpc.aws_route_table.public: Creation complete after 1s [id=rtb-0651630c632c1c326]
module.vpc.aws_internet_gateway.igw: Creation complete after 1s [id=igw-0ca8ab79f7534cb34]
module.vpc.aws_route.public_internet: Creating...
module.vpc.aws_route_table.private: Creation complete after 1s [id=rtb-07f0922ee4b729ec2]
module.vpc.aws_subnet.private[2]: Creation complete after 1s [id=subnet-0e9aef45421e7e44e]
module.vpc.aws_route.public_internet: Creation complete after 1s [id=r-rtb-0651630c632c1c3261080289494]
module.vpc.aws_subnet.private[1]: Creation complete after 3s [id=subnet-05254baa162ab14ef]
module.vpc.aws_subnet.private[0]: Creation complete after 3s [id=subnet-0825d40b78deffb27]
module.vpc.aws_route_table_association.private[2]: Creating...
module.vpc.aws_route_table_association.private[0]: Creating...
module.vpc.aws_route_table_association.private[1]: Creating...
module.vpc.aws_route_table_association.private[0]: Creation complete after 1s [id=rtbassoc-05baa233d01ea9b06]
module.vpc.aws_route_table_association.private[1]: Creation complete after 1s [id=rtbassoc-0251bcf1f92c93055]
module.vpc.aws_route_table_association.private[2]: Creation complete after 1s [id=rtbassoc-012fe51d1f49c3fe2]
module.vpc.aws_subnet.public[2]: Still creating... [00m10s elapsed]
module.vpc.aws_subnet.public[1]: Still creating... [00m10s elapsed]
module.vpc.aws_subnet.public[0]: Still creating... [00m10s elapsed]
module.vpc.aws_subnet.public[2]: Creation complete after 11s [id=subnet-05ce9c9f1b8c0ee44]
module.vpc.aws_subnet.public[0]: Creation complete after 12s [id=subnet-0f4db970a33ed4fcc]
module.vpc.aws_nat_gateway.nat: Creating...
module.vpc.aws_subnet.public[1]: Creation complete after 13s [id=subnet-05229e85c274ae047]
module.vpc.aws_route_table_association.public[2]: Creating...
module.vpc.aws_route_table_association.public[1]: Creating...
module.vpc.aws_route_table_association.public[0]: Creating...
module.vpc.aws_route_table_association.public[2]: Creation complete after 1s [id=rtbassoc-0579a252b30c8629a]
module.vpc.aws_route_table_association.public[0]: Creation complete after 1s [id=rtbassoc-0b712537bfdce83fd]
module.vpc.aws_route_table_association.public[1]: Creation complete after 1s [id=rtbassoc-0254a76ee8e30ed57]
module.vpc.aws_nat_gateway.nat: Still creating... [00m10s elapsed]
module.vpc.aws_nat_gateway.nat: Still creating... [00m20s elapsed]
module.vpc.aws_nat_gateway.nat: Still creating... [00m30s elapsed]
module.vpc.aws_nat_gateway.nat: Still creating... [00m40s elapsed]
module.vpc.aws_nat_gateway.nat: Still creating... [00m50s elapsed]
module.vpc.aws_nat_gateway.nat: Still creating... [01m00s elapsed]
module.vpc.aws_nat_gateway.nat: Still creating... [01m10s elapsed]
module.vpc.aws_nat_gateway.nat: Still creating... [01m20s elapsed]
module.vpc.aws_nat_gateway.nat: Still creating... [01m30s elapsed]
module.vpc.aws_nat_gateway.nat: Still creating... [01m40s elapsed]
module.vpc.aws_nat_gateway.nat: Creation complete after 1m44s [id=nat-03855f8cb76e614fc]
module.vpc.aws_route.private_nat: Creating...
module.vpc.aws_route.private_nat: Creation complete after 0s [id=r-rtb-07f0922ee4b729ec21080289494]
```
