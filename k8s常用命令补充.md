# k8s常用命令补充

1. 查看pod详细信息

```
kubectl -n backend get  pod/myapp-7b9f486cf9-9rfpg -o wide
```

2. 查看pod描述

```
kubectl -n backend describe myapp-7b9f486cf9-9rfpg
```



1. 进入 pod 内的容器：

```
kubectl -n backend  exec -it myapp-7b9f486cf9-9rfpg -c filebeat-myapp -- bash
```

> 双横杠（--）代表 kubectl 命令项的结束，在双横杠后面的内容是指pod内部需要执行的命令。
