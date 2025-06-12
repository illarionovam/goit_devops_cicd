# lesson 7

Що робила по частинах.

## Підготовка

Потім створила модуль eks та підкоригувала модуль ecr (додала додаткові полісі, щоб можна було пушити образи). Також прибрала (закоментила) NAT Gateway з vpc модуля, бо він забирає дуже багато грошей, а конкретно для цього дз він не є важливим.

Ну, і завантажила екосистему за допомогою тераформ в AWS.

```
Outputs:

dynamodb_table_name = "terraform-locks"
eks_cluster_endpoint = "https://DE781A2F35C003BDEACC35E7D3BBEFBD.gr7.eu-central-1.eks.amazonaws.com"
eks_cluster_name = "eks-cluster-demo"
eks_node_role_arn = "arn:aws:iam::748257756796:role/eks-cluster-demo-eks-nodes"
internet_gateway_id = "igw-0159b569ecd2aed7e"
private_subnets = [
  "subnet-08ba1ba0f1c3a9a12",
  "subnet-0807cdfd39b88a807",
  "subnet-073006d6cab10fe54",
]
public_subnets = [
  "subnet-0b1a3adeb3f8cd5c2",
  "subnet-08b607542a95b1e8f",
  "subnet-044b862474e9a866d",
]
repository_arn = "arn:aws:ecr:eu-central-1:748257756796:repository/lesson-5-ecr"
repository_url = "748257756796.dkr.ecr.eu-central-1.amazonaws.com/lesson-5-ecr"
s3_bucket_name = "terraform-state-bucket-455062"
vpc_id = "vpc-0686e4f864edf8758"
```

## Забезпечте доступ до кластера за допомогою kubectl.

Додала кластер до kubeconfig.

```
aws eks --region eu-central-1 update-kubeconfig --name eks-cluster-demo
Added new context arn:aws:eks:eu-central-1:748257756796:cluster/eks-cluster-demo to /home/mariia/.kube/config
```

## Завантажте Docker-образ Django, який ви створювали в темі 4, до ECR, використовуючи AWS CLI.

Залогінилась докером у свій ecr.

```
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 748257756796.dkr.ecr.eu-central-1.amazonaws.com
```

Стягнула докер імедж локально.

```
docker pull dolaxid/my-django-app:latest
```

Тегнула.

```
docker tag dolaxid/my-django-app:latest 748257756796.dkr.ecr.eu-central-1.amazonaws.com/lesson-5-ecr:latest
```

Запушила в ecr.

```
docker push 748257756796.dkr.ecr.eu-central-1.amazonaws.com/lesson-5-ecr:latest
```

## Запускаємо helm.

```
helm install django charts/django-app --values charts/django-app/values.yaml
```
