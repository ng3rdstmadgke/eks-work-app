# 開発環境起動

```bash
# 開発モード
./bin/run.sh

# 本番モード
./bin/run.sh prd
```

# イメージのビルドとECRへのプッシュ

```bash
./bin/build.sh push
```

# update-kubeconfig

```bash
aws eks --region ap-northeast-1 update-kubeconfig --name eks-work-prd
```

# アプリのデプロイ

作成

```bash
STAGE=production

# 作成されるリソース一覧
$ kubectl kustomize kustomize/overlays/$STAGE

# kustomizeを利用してリソースをデプロイ
# -k: kustomization directoryを指定
$ kubectl apply -k kustomize/overlays/$STAGE
```

確認

```bash
# deploymentの確認
$ kubectl get deployment -n $STAGE
NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
eks-work-app-backend    2/2     2            2           25m
eks-work-app-frontend   2/2     2            2           25m
eks-work-app-nginx      2/2     2            2           25m

# serviceの確認
$ kubectl get svc -n $STAGE
NAME                    TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
backend-eks-work-app    ClusterIP   172.20.84.74     <none>        8000/TCP       63s
frontend-eks-work-app   ClusterIP   172.20.121.36    <none>        3000/TCP       63s
nginx-eks-work-app      NodePort    172.20.170.129   <none>        80:30135/TCP   63s

# ALBのURLを確認 
$ kubectl get ing -n $STAGE
NAME      CLASS   HOSTS   ADDRESS                                                                     PORTS   AGE
ingress   alb     *       k8s-producti-ingress-xxxxxxxxxx-xxxxxxxx.ap-northeast-1.elb.amazonaws.com   80      26m

# Podのイメージタグを確認
$ kubectl get pod -o json -n $STAGE | jq -r ".items[].spec.containers[].image"
xxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/eks-work-app/backend:latest
xxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/eks-work-app/backend:latest
xxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/eks-work-app/backend:latest
xxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/eks-work-app/backend:latest
xxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/eks-work-app/frontend:latest
xxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/eks-work-app/frontend:latest
xxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/eks-work-app/frontend:latest
xxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/eks-work-app/frontend:latest
xxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/eks-work-app/nginx:latest
xxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/eks-work-app/nginx:latest
xxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/eks-work-app/nginx:latest
```

削除

```bash
# 個別のリソースの削除
kubectl delete svc nginx-eks-work-app-service -n $STAGE

# 削除
$ kubectl delete -k kustomize/overlays/$STAGE
```