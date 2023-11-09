# Momo Store aka Пельменная №2

<img width="900" alt="image" src="https://user-images.githubusercontent.com/9394918/167876466-2c530828-d658-4efe-9064-825626cc6db5.png">

## Frontend

```bash
npm install
NODE_ENV=production VUE_APP_API_URL=http://localhost:8081 npm run serve

```

```

## Backend

```bash
go run ./cmd/api
go test -v ./... 
```

## Приложение [Momo-store](https://momo-store.lightstandart.com/)

## CI/CD

- используется единый [репозиторий](https://gitlab.praktikum-services.ru/d.ponizovskiy/momo-store)
- развертывание приложение осуществляется с использованием [Downstream pipeline]
- при изменениях в соответствующих директориях триггерятся pipeline для backend, frontend и infrastructure (momo-store-chart)
- backend и frontend проходят этапы сборки, тестирования, релиза
- momo-store-helm проходит этапы релиза и деплоя в prod-окружение (k8s)

## Versioning

- мажорные и минорные версии приложения изменяются вручную в файлах `backend/.gitlab-ci.yaml` и `frontend/.gitlab-ci.yaml` в переменной `VERSION`
- патч-версии изменяются автоматически на основе переменной `CI_PIPELINE_ID`
- для инфраструктуры мажорные и минорные версии меняются в в файле `infrastructure/momo-store-chart/Chart.yaml` приложения изменяется автоматически на основе переменной `CI_PIPELINE_ID`

## Infrastructure

- код ---> [Gitlab](https://gitlab.praktikum-services.ru/)
- helm-charts ---> [Nexus](https://nexus.praktikum-services.ru/)
- анализ кода ---> [SonarQube](https://sonarqube.praktikum-services.ru/)
- docker-images ---> [Gitlab Container Registry](https://gitlab.praktikum-services.ru/d.ponizovksiy/momo-store/container_registry)
- терраформ бэкэнд и статика ---> [Yandex Object Storage](https://cloud.yandex.ru/services/storage)
- продакшн ---> [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)

## Init kubernetes

- клонировать репозиторий на машину с установленным terraform
- через консоль Yandex Cloud создать сервисный аккаунт с ролью `editor`, получить статический ключ доступа, сохранить секретный ключ в файле `infrastructure/terraform/backend.tfvars`
```
        #Keys for service account
        access_key="........."
        secret_key="........."
```
- получить [iam-token](https://cloud.yandex.ru/docs/iam/operations/iam-token/create)
- сохранить [iam-token] [cloud_id] [folder_id] [network_zone] в файле `infrastructure/terraform/terraform.tfvars`

- через консоль Yandex Cloud создать Object Storage, внести параметры подключения в файл `infrastructure/terraform/provider.tf`
- выполнить следующие комманды:
```
cd infrastructure/terraform
terraform init -backend-config=backend.tfvars
terraform apply
```

## Init production

# устанавливаем cert-manager
```
cd infrastructure/momo-store-chart/
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade --install --atomic -n default cert-manager jetstack/cert-manager --version v1.9.1 --set installCRDs=true
```

# получаем kubeconfig
```
yc managed-kubernetes cluster get-credentials momo-store-k8s-cluster --external
```

# устанавливаем ingress-controller
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx
```

# устанавливаем приложение
```
helm upgrade --install --atomic -n default momo-store .
```

# смотрим IP load balancer, прописываем А-записи для приложения и мониторинга
```
kubectl get svc
```


## Backlog

- развернуть мониторинг состояния кластера и приложения
- добавить тестовое окружение (отдельная ВМ, отдельный кластер или отдельный namespace)
- вывести мониторинг из чарта самого приложения (ускорить деплой)
- поднять Vault для хранения секретов
