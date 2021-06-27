# 运行一个 app
1. 运行一个 Deployment ：`kubectl run nginx-deployment --image=nginx:1.7.9 --replicas=2`
```
[root@ip-172-31-24-224 ~]# kubectl run nginx-deployment --image=nginx:1.7.9 --replicas=2
deployment.apps "nginx-deployment" created
```

1. 查看 `nginx-deployment` 的状态 ： ``` kubectl get deployment ```
```
[root@ip-172-31-24-224 ~]# kubectl get deployment
NAME               DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
my-nginx           2         2         2            2           9d
nginx              2         2         2            2           9d
nginx-deployment   2         2         2            2           3m
```

1. 获取更详细的信息 : `kubectl describe deployment nginx-deployment`
```
[root@ip-172-31-24-224 ~]# kubectl describe deployment nginx-deployment
Name:                   nginx-deployment
Namespace:              default
CreationTimestamp:      Mon, 27 Aug 2018 08:21:46 +0000
Labels:                 run=nginx-deployment
Annotations:            deployment.kubernetes.io/revision=1
Selector:               run=nginx-deployment
Replicas:               2 desired | 2 updated | 2 total | 2 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  1 max unavailable, 1 max surge
Pod Template:
  Labels:  run=nginx-deployment
  Containers:
   nginx-deployment:
    Image:        nginx:1.7.9
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   nginx-deployment-6b5c99b6fd (2/2 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  6m    deployment-controller  Scaled up replica set nginx-deployment-6b5c99b6fd to 2
```

1. 查看 `nginx-deployment` 的副本信息： `kubectl get replicaset`  
```
[root@ip-172-31-24-224 ~]# kubectl get replicaset 
NAME                          DESIRED   CURRENT   READY     AGE
my-nginx-6fbbf44477           2         2         2         9d
nginx-6795bb46c6              2         2         2         9d
nginx-deployment-6b5c99b6fd   2         2         2         12m
[root@ip-172-31-24-224 ~]# kubectl describe replicaset nginx-deployment-6b5c99b6fd
Name:           nginx-deployment-6b5c99b6fd
Namespace:      default
Selector:       pod-template-hash=2617556298,run=nginx-deployment
Labels:         pod-template-hash=2617556298
                run=nginx-deployment
Annotations:    deployment.kubernetes.io/desired-replicas=2
                deployment.kubernetes.io/max-replicas=3
                deployment.kubernetes.io/revision=1
Controlled By:  Deployment/nginx-deployment
Replicas:       2 current / 2 desired
Pods Status:    2 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  pod-template-hash=2617556298
           run=nginx-deployment
  Containers:
   nginx-deployment:
    Image:        nginx:1.7.9
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Events:
  Type    Reason            Age   From                   Message
  ----    ------            ----  ----                   -------
  Normal  SuccessfulCreate  12m   replicaset-controller  Created pod: nginx-deployment-6b5c99b6fd-gqlkk
  Normal  SuccessfulCreate  12m   replicaset-controller  Created pod: nginx-deployment-6b5c99b6fd-7wzpr
```

1. 查看 `nginx-deployment` 的 pod 信息： `kubectl get pod`  
```
[root@ip-172-31-24-224 ~]# kubectl get pod
NAME                                READY     STATUS    RESTARTS   AGE
my-nginx-6fbbf44477-qx82f           1/1       Running   0          9d
my-nginx-6fbbf44477-s9jjz           1/1       Running   0          9d
nginx-6795bb46c6-42n6k              1/1       Running   0          9d
nginx-6795bb46c6-wx5qz              1/1       Running   0          9d
nginx-deployment-6b5c99b6fd-7wzpr   1/1       Running   0          15m
nginx-deployment-6b5c99b6fd-gqlkk   1/1       Running   0          15m
```

```
[root@ip-172-31-24-224 ~]# kubectl describe pod nginx-deployment
Name:           nginx-deployment-6b5c99b6fd-7wzpr
Namespace:      default
Node:           172.31.24.224/172.31.24.224
Start Time:     Mon, 27 Aug 2018 08:21:48 +0000
Labels:         pod-template-hash=2617556298
                run=nginx-deployment
Annotations:    <none>
Status:         Running
IP:             172.17.0.7
Controlled By:  ReplicaSet/nginx-deployment-6b5c99b6fd
Containers:
  nginx-deployment:
    Container ID:   docker://7d557ad91072c93e4a5eb99b188101fa8c119f88376cd13a3b13cbee3cbc7838
    Image:          nginx:1.7.9
    Image ID:       docker-pullable://nginx@sha256:e3456c851a152494c3e4ff5fcc26f240206abac0c9d794affb40e0714846c451
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Mon, 27 Aug 2018 08:23:53 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-nnzt6 (ro)
Conditions:
  Type           Status
  Initialized    True 
  Ready          True 
  PodScheduled   True 
Volumes:
  default-token-nnzt6:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-nnzt6
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     <none>
Events:
  Type    Reason                 Age   From                    Message
  ----    ------                 ----  ----                    -------
  Normal  Scheduled              19m   default-scheduler       Successfully assigned nginx-deployment-6b5c99b6fd-7wzpr to 172.31.24.224
  Normal  SuccessfulMountVolume  19m   kubelet, 172.31.24.224  MountVolume.SetUp succeeded for volume "default-token-nnzt6"
  Normal  Pulling                19m   kubelet, 172.31.24.224  pulling image "nginx:1.7.9"
  Normal  Pulled                 17m   kubelet, 172.31.24.224  Successfully pulled image "nginx:1.7.9"
  Normal  Created                17m   kubelet, 172.31.24.224  Created container
  Normal  Started                17m   kubelet, 172.31.24.224  Started container

Name:           nginx-deployment-6b5c99b6fd-gqlkk
Namespace:      default
Node:           172.31.25.125/172.31.25.125
Start Time:     Mon, 27 Aug 2018 08:21:48 +0000
Labels:         pod-template-hash=2617556298
                run=nginx-deployment
Annotations:    <none>
Status:         Running
IP:             172.17.0.5
Controlled By:  ReplicaSet/nginx-deployment-6b5c99b6fd
Containers:
  nginx-deployment:
    Container ID:   docker://4b506b47f90f7c8459d11e15639b3414189256d2f5458d74d5000ebf4ed41541
    Image:          nginx:1.7.9
    Image ID:       docker-pullable://nginx@sha256:e3456c851a152494c3e4ff5fcc26f240206abac0c9d794affb40e0714846c451
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Mon, 27 Aug 2018 08:22:13 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-nnzt6 (ro)
Conditions:
  Type           Status
  Initialized    True 
  Ready          True 
  PodScheduled   True 
Volumes:
  default-token-nnzt6:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-nnzt6
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     <none>
Events:
  Type    Reason                 Age   From                    Message
  ----    ------                 ----  ----                    -------
  Normal  Scheduled              19m   default-scheduler       Successfully assigned nginx-deployment-6b5c99b6fd-gqlkk to 172.31.25.125
  Normal  SuccessfulMountVolume  19m   kubelet, 172.31.25.125  MountVolume.SetUp succeeded for volume "default-token-nnzt6"
  Normal  Pulled                 19m   kubelet, 172.31.25.125  Container image "nginx:1.7.9" already present on machine
  Normal  Created                19m   kubelet, 172.31.25.125  Created container
  Normal  Started                18m   kubelet, 172.31.25.125  Started container
```

# 总结

1. 用户通过 kubectl 创建 Deployment。
2. Deployment 创建 ReplicaSet。
3. ReplicaSet 创建 Pod。


对象的命名方式是：子对象的名字 = 父对象名字 + 随机字符串或数字。