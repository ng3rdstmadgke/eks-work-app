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