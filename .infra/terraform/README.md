Деплой кластера

    terraform init
    terraform apply

Импорт контекста в kubectl

    aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
    aws eks --region eu-west-2 update-kubeconfig --name diploma-eks

Деплой prometheus grafana

    helm\kube-prometheus-stack>helm install prom ./



