# ■ 開発環境起動

```bash
# 開発モード
./bin/run.sh

# 本番モード
./bin/run.sh prd
```

`nginx-eks-work-app:80` をポートフォワード


# ■ イメージのビルドとECRへのプッシュ

```bash
./bin/build.sh push
```

# ■ update-kubeconfig

```bash
aws eks --region ap-northeast-1 update-kubeconfig --name eks-work-prd
```

# ■ 手動でのアプリのデプロイ

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

# ■ Fluxを利用したアプリのデプロイ

```bash
aws eks update-kubeconfig --name eks-work-prd
```

## Fluxツールキットコンポーネントのインストール・Fluxリポジトリの自動生成

```bash
export GITHUB_TOKEN= ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
export GITHUB_USER=ng3rdstmadgke

# Fluxマニフェストを管理するGitHubリポジトリを作成し、Fluxツールキットコンポーネントをクラスタにデプロイする
# flux bootstrap githubコマンド: https://fluxcd.io/flux/cmd/flux_bootstrap/
flux bootstrap github \
  --owner=${GITHUB_USER} \
  --repository=eks-work-flux\
  --branch=main \
  --path=eks-work-app \
  --personal

# ツールキットコンポーネントの確認
# Toolkit components: https://fluxcd.io/flux/components/
kubectl get deployment -n flux-system
```

## Fluxリポジトリに設定ファイルを作成

```bash
git clone git@github.com:ng3rdstmadgke/eks-work-flux.git
cd eks-work-flux/

export GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
export GITHUB_USER=ng3rdstmadgke

mkdir eks-work-app/production

# SourceController: GitHubやS3などに保管されるソースコードを取得するための共通インターフェースを提供します。
# - flux create source gitコマンド
#   https://fluxcd.io/flux/cmd/flux_bootstrap_github/
# - Source Controller
#   https://fluxcd.io/flux/components/source/
#   - GitRepositoryマニフェスト
#     https://fluxcd.io/flux/components/source/gitrepositories/
flux create source git eks-work-app-production \
  --url=https://github.com/${GITHUB_USER}/eks-work-app \
  --branch=main \
  --interval=30s \
  --export > ./eks-work-app/production/app-source.yaml 

# Kustomize Controller: Source Controllerで取得したアーティファクト内のKustomizeマニフェストを取得し、Kubernetesクラスタに適用するためのパイプラインを定義します
# - flux create kustomization コマンド
#   https://fluxcd.io/flux/cmd/flux_create_kustomization/
# - KustomizeController
#   https://fluxcd.io/flux/components/kustomize/
#   - Kustomizationマニフェスト
#     https://fluxcd.io/flux/components/kustomize/kustomizations/
flux create kustomization eks-work-app-production \
  --target-namespace=production \
  --source=eks-work-app-production \
  --path="./kustomize/overlays/production" \
  --prune=true \
  --interval=1m \
  --export > ./eks-work-app/production/app-sync.yaml

# コミットしてプッシュ
git add .
git commit -m "first commit"
git push origin main

```

## ソースを修正してデプロイされるか確認

```bash
cd eks-work-app
git checkout -B feature/test01 origin/main
git add .
git commit -m “test”
git push origin feature/test01

# GitHub側でプルリクエストを作成してマージ
```

# ■ ArgoCDを利用したアプリのデプロイ

## ArgoCDのインストール

```bash
kubectl create namespace argocd

# サービスの作成
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

## ソースを修正してデプロイされるか確認

```bash
cd eks-work-app
git checkout -B feature/test01 origin/main
git add .
git commit -m “test”
git push origin feature/test01

# GitHub側でプルリクエストを作成してマージ
```


# ■ リソースのクリーンアップ

```bash
# ClusterにインストールしたFluxツールキットコンポーネントをアンインストール
flux uninstall --namespace=flux-system

# Kustomizeで作成したIngressリソースを含むDeploymentなどのリソースの削除
# Ingressが削除されることでALBも自動的に削除されます
kubectl delete -k kustomize/overlays/staging
kubectl delete -k kustomize/overlays/production
```