# secrets

```
kubectl create secret docker-registry harbor-secret \
	--namespace=kube-system \
	--docker-server=202.116.46.215 \
	--docker-username=lipengfei \
	--docker-password=LiPengFei1993
```

kubectl create secret docker-registry registry-secret \
	--namespace=kube-system \
	--docker-server=reg.harbor.com \
	--docker-username=admin \
	--docker-password=Harbor12345


```
kubectl edit secret  harbor-secret -n kube-system
```


```
# vim coredns.yaml
  ....
  containers:
  - name: coredns
    image: reg.harbor.com/k8s/coredns:1.2.6
    imagePullPolicy: IfNotPresent
  ....
  imagePullSecrets:
  - name: harbor-secrets
```