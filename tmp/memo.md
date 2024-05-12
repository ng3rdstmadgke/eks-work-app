```bash
# デプロイ
$ kubectl apply -f deployment.yaml 

# サービスの確認
$ kubectl get svc
NAME                    TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
backend-eks-work-app    ClusterIP   172.20.235.140   <none>        8000/TCP   27m
frontend-eks-work-app   ClusterIP   172.20.225.73    <none>        3000/TCP   24m
kubernetes              ClusterIP   172.20.0.1       <none>        443/TCP    4d1h

# デプロイメントの確認
$ kubectl get deployment
NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
eks-work-app-backend    3/3     3            3           38m
eks-work-app-frontend   3/3     3            3           26m
eks-work-app-nginx      2/2     2            2           18m

# Podの確認
$ kubectl get po
NAME                                     READY   STATUS    RESTARTS   AGE
eks-work-app-backend-65876d6d7b-ljknd    1/1     Running   0          38m
eks-work-app-backend-65876d6d7b-mhmgr    1/1     Running   0          38m
eks-work-app-backend-65876d6d7b-rnddc    1/1     Running   0          38m
eks-work-app-frontend-56858968c9-fkqbx   1/1     Running   0          26m
eks-work-app-frontend-56858968c9-xt5zt   1/1     Running   0          26m
eks-work-app-frontend-56858968c9-zrx4c   1/1     Running   0          26m
eks-work-app-nginx-f9d94fc7b-brt6b       1/1     Running   0          19m
eks-work-app-nginx-f9d94fc7b-mlfwk       1/1     Running   0          19m

# nginxのコンテナからbackendにリクエストを送信
kubectl exec -it eks-work-app-nginx-f9d94fc7b-brt6b -c eks-work-app-nginx -- curl "http://backend-eks-work-app:8000/api"

# 削除
kubectl delete -f deployment.yaml
```