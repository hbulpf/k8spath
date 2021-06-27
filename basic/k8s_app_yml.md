# yml 配置
yaml 常用命令：  
```
kubectl apply
kubectl create
kubectl replace
kubectl edit 
kubectl patch
```
# 使用 yml 运行一个 app

1. 运行一个 Deployment ：`kubectl apply -f nginx.yml`   
  `nginx.yml`的配置信息：
  ```
  apiVersion: extensions/v1beta1
  kind: Deployment 
  metadata: 
    name: nginx-deployment2
  spec: 
    replicas: 2
    template: 
      metadata: 
        labels: 
          app: web_server 
      spec: 
        containers: 
        - name: nginx 
          image: nginx:1.7.9 
          ports: 
          - containerPort: 80 
  ```

  > ① apiVersion 是当前配置格式的版本。   
    ② kind 是要创建的资源类型，这里是 Deployment。   
    ③ metadata 是该资源的元数据，name 是必需的元数据项。   
    ④ spec 部分是该 Deployment 的规格说明。   
    ⑤ replicas 指明副本数量，默认为 1。  
    ⑥ template 定义 Pod 的模板，这是配置文件的重要部分。  
    ⑦ metadata 定义 Pod 的元数据，至少要定义一个 label。label 的 key 和 value 可以任意指定。   
  > ⑧ spec 描述 Pod 的规格，此部分定义 Pod 中每一个容器的属性，name 和 image 是必需的。

  **注：填写 apiVersion 的值时，使用 `kubectl api-versions` 查看 k8s 支持的api版本**
  ```
  [root@ip-172-31-24-224 opt]# kubectl api-versions
  admissionregistration.k8s.io/v1beta1
  apiextensions.k8s.io/v1beta1
  apiregistration.k8s.io/v1
  apiregistration.k8s.io/v1beta1
  apps/v1
  apps/v1beta1
  apps/v1beta2
  authentication.k8s.io/v1
  authentication.k8s.io/v1beta1
  authorization.k8s.io/v1
  authorization.k8s.io/v1beta1
  autoscaling/v1
  autoscaling/v2beta1
  batch/v1
  batch/v1beta1
  certificates.k8s.io/v1beta1
  events.k8s.io/v1beta1
  extensions/v1beta1
  networking.k8s.io/v1
  policy/v1beta1
  rbac.authorization.k8s.io/v1
  rbac.authorization.k8s.io/v1beta1
  storage.k8s.io/v1
  storage.k8s.io/v1beta1
  v1
  ```

2. 查看 Deployment ： `kubectl get deployment nginx-deployment2 -o wide`
  ```
  [root@ip-172-31-24-224 opt]# kubectl get deployment nginx-deployment2 -o wide
  NAME                DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE       CONTAINERS   IMAGES        SELECTOR
  nginx-deployment2   2         2         2            2           9m        nginx        nginx:1.7.9   app=web_server
  [root@ip-172-31-24-224 opt]# kubectl describe deployment nginx-deployment2
  Name:                   nginx-deployment2
  Namespace:              default
  CreationTimestamp:      Mon, 27 Aug 2018 09:10:16 +0000
  Labels:                 app=web_server
  Annotations:            deployment.kubernetes.io/revision=1
                          kubectl.kubernetes.io/last-applied-configuration={"apiVersion":"extensions/v1beta1","kind":"Deployment","metadata":{"annotations":{},"name":"nginx-deployment2","namespace":"default"},"spec":{"replicas...
  Selector:               app=web_server
  Replicas:               2 desired | 2 updated | 2 total | 2 available | 0 unavailable
  StrategyType:           RollingUpdate
  MinReadySeconds:        0
  RollingUpdateStrategy:  1 max unavailable, 1 max surge
  Pod Template:
    Labels:  app=web_server
    Containers:
     nginx:
      Image:        nginx:1.7.9
      Port:         80/TCP
      Host Port:    0/TCP
      Environment:  <none>
      Mounts:       <none>
    Volumes:        <none>
  Conditions:
    Type           Status  Reason
    ----           ------  ------
    Available      True    MinimumReplicasAvailable
    Progressing    True    NewReplicaSetAvailable
  OldReplicaSets:  <none>
  NewReplicaSet:   nginx-deployment2-7f7c47b54f (2/2 replicas created)
  Events:
    Type    Reason             Age   From                   Message
    ----    ------             ----  ----                   -------
    Normal  ScalingReplicaSet  9m    deployment-controller  Scaled up replica set nginx-deployment2-7f7c47b54f to 2
  ```

3. 删除 Deployment ： `kubectl delete deployment nginx-deployment2` 或者 `kubectl delete -f nginx.yml`
  ```
  [root@ip-172-31-24-224 opt]# kubectl delete -f nginx.yml

  deployment.extensions "nginx-deployment2" deleted
  ```