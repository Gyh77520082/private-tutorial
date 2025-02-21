# helm-charts使用说明

创建helm的charts

    helm create mychart

打包

    helm package mychart

更新索引

    helm repo index <D:\work\helm-charts>

文件上传至服务器

    上传index.yaml 和tgz文件至10.10.114.7@/data/nginx/website/helm-charts

添加仓库

    helm repo add gyhy_helm_charts http://10.10.114.7/helm-charts/ --insecure-skip-tls-verify
