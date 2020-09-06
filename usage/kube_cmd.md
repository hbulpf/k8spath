# kubectl 命令技巧大全

Kubctl 命令是操作 kubernetes 集群的最直接和最 skillful 的途径，这个60多MB大小的二进制文件，到底有啥能耐呢？请看下文：

## Kubectl 自动补全

```bash
$ source <(kubectl completion bash) # setup autocomplete in bash, bash-completion package should be installed first.
$ source <(kubectl completion zsh)  # setup autocomplete in zsh
```

## Kubectl 上下文和配置

设置 `kubectl` 命令交互的 kubernetes 集群并修改配置信息。参阅 [使用 kubeconfig 文件进行跨集群验证](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters) 获取关于配置文件的详细信息。

```bash
$ kubectl config view # 显示合并后的 kubeconfig 配置

# 同时使用多个 kubeconfig 文件并查看合并后的配置
$ KUBECONFIG=~/.kube/config:~/.kube/kubconfig2 kubectl config view

# 获取 e2e 用户的密码
$ kubectl config view -o jsonpath='{.users[?(@.name == "e2e")].user.password}'

$ kubectl config current-context              # 显示当前的上下文
$ kubectl config use-context my-cluster-name  # 设置默认上下文为 my-cluster-name

# 向 kubeconf 中增加支持基本认证的新集群
$ kubectl config set-credentials kubeuser/foo.kubernetes.com --username=kubeuser --password=kubepassword

# 使用指定的用户名和 namespace 设置上下文
$ kubectl config set-context gce --user=cluster-admin --namespace=foo \
  && kubectl config use-context gce
```

## 创建对象

Kubernetes 的清单文件可以使用 json 或 yaml 格式定义。可以以 `.yaml`、`.yml`、或者 `.json` 为扩展名。

```yaml
$ kubectl create -f ./my-manifest.yaml           # 创建资源
$ kubectl create -f ./my1.yaml -f ./my2.yaml     # 使用多个文件创建资源
$ kubectl create -f ./dir                        # 使用目录下的所有清单文件来创建资源
$ kubectl create -f https://git.io/vPieo         # 使用 url 来创建资源
$ kubectl run nginx --image=nginx                # 启动一个 nginx 实例
$ kubectl explain pods,svc                       # 获取 pod 和 svc 的文档

# 从 stdin 输入中创建多个 YAML 对象
$ cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: busybox-sleep
spec:
  containers:
  - name: busybox
    image: busybox
    args:
    - sleep
    - "1000000"
---
apiVersion: v1
kind: Pod
metadata:
  name: busybox-sleep-less
spec:
  containers:
  - name: busybox
    image: busybox
    args:
    - sleep
    - "1000"
EOF

# 创建包含几个 key 的 Secret
$ cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:
  password: $(echo "s33msi4" | base64)
  username: $(echo "jane" | base64)
EOF

```

## 显示和查找资源

```bash
# Get commands with basic output
$ kubectl get services                          # 列出所有 namespace 中的所有 service
$ kubectl get pods --all-namespaces             # 列出所有 namespace 中的所有 pod
$ kubectl get pods -o wide                      # 列出所有 pod 并显示详细信息
$ kubectl get deployment my-dep                 # 列出指定 deployment
$ kubectl get pods --include-uninitialized      # 列出该 namespace 中的所有 pod 包括未初始化的

# 使用详细输出来描述命令
$ kubectl describe nodes my-node
$ kubectl describe pods my-pod

$ kubectl get services --sort-by=.metadata.name # List Services Sorted by Name

# 根据重启次数排序列出 pod
$ kubectl get pods --sort-by='.status.containerStatuses[0].restartCount'

# 获取所有具有 app=cassandra 的 pod 中的 version 标签
$ kubectl get pods --selector=app=cassandra rc -o \
  jsonpath='{.items[*].metadata.labels.version}'

# 获取所有节点的 ExternalIP
$ kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}'

# 列出属于某个 PC 的 Pod 的名字
# “jq”命令用于转换复杂的 jsonpath，参考 https://stedolan.github.io/jq/
$ sel=${$(kubectl get rc my-rc --output=json | jq -j '.spec.selector | to_entries | .[] | "\(.key)=\(.value),"')%?}
$ echo $(kubectl get pods --selector=$sel --output=jsonpath={.items..metadata.name})

# 查看哪些节点已就绪
$ JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}' \
 && kubectl get nodes -o jsonpath="$JSONPATH" | grep "Ready=True"

# 列出当前 Pod 中使用的 Secret
$ kubectl get pods -o json | jq '.items[].spec.containers[].env[]?.valueFrom.secretKeyRef.name' | grep -v null | sort | uniq
```

## 更新资源

```bash
$ kubectl rolling-update frontend-v1 -f frontend-v2.json           # 滚动更新 pod frontend-v1
$ kubectl rolling-update frontend-v1 frontend-v2 --image=image:v2  # 更新资源名称并更新镜像
$ kubectl rolling-update frontend --image=image:v2                 # 更新 frontend pod 中的镜像
$ kubectl rolling-update frontend-v1 frontend-v2 --rollback        # 退出已存在的进行中的滚动更新
$ cat pod.json | kubectl replace -f -                              # 基于 stdin 输入的 JSON 替换 pod

# 强制替换，删除后重新创建资源。会导致服务中断。
$ kubectl replace --force -f ./pod.json

# 为 nginx RC 创建服务，启用本地 80 端口连接到容器上的 8000 端口
$ kubectl expose rc nginx --port=80 --target-port=8000

# 更新单容器 pod 的镜像版本（tag）到 v4
$ kubectl get pod mypod -o yaml | sed 's/\(image: myimage\):.*$/\1:v4/' | kubectl replace -f -

$ kubectl label pods my-pod new-label=awesome                      # 添加标签
$ kubectl annotate pods my-pod icon-url=http://goo.gl/XXBTWq       # 添加注解
$ kubectl autoscale deployment foo --min=2 --max=10                # 自动扩展 deployment “foo”
```

## 修补资源

使用策略合并补丁并修补资源。

```bash
$ kubectl patch node k8s-node-1 -p '{"spec":{"unschedulable":true}}' # 部分更新节点

# 更新容器镜像； spec.containers[*].name 是必须的，因为这是合并的关键字
$ kubectl patch pod valid-pod -p '{"spec":{"containers":[{"name":"kubernetes-serve-hostname","image":"new image"}]}}'

# 使用具有位置数组的 json 补丁更新容器镜像
$ kubectl patch pod valid-pod --type='json' -p='[{"op": "replace", "path": "/spec/containers/0/image", "value":"new image"}]'

# 使用具有位置数组的 json 补丁禁用 deployment 的 livenessProbe
$ kubectl patch deployment valid-deployment  --type json   -p='[{"op": "remove", "path": "/spec/template/spec/containers/0/livenessProbe"}]'
```

## 编辑资源

在编辑器中编辑任何 API 资源。

```bash
$ kubectl edit svc/docker-registry                      # 编辑名为 docker-registry 的 service
$ KUBE_EDITOR="nano" kubectl edit svc/docker-registry   # 使用其它编辑器
```

## Scale 资源

```bash
$ kubectl scale --replicas=3 rs/foo                                 # Scale a replicaset named 'foo' to 3
$ kubectl scale --replicas=3 -f foo.yaml                            # Scale a resource specified in "foo.yaml" to 3
$ kubectl scale --current-replicas=2 --replicas=3 deployment/mysql  # If the deployment named mysql's current size is 2, scale mysql to 3
$ kubectl scale --replicas=5 rc/foo rc/bar rc/baz                   # Scale multiple replication controllers
```

## 删除资源

```bash
$ kubectl delete -f ./pod.json                                              # 删除 pod.json 文件中定义的类型和名称的 pod
$ kubectl delete pod,service baz foo                                        # 删除名为“baz”的 pod 和名为“foo”的 service
$ kubectl delete pods,services -l name=myLabel                              # 删除具有 name=myLabel 标签的 pod 和 serivce
$ kubectl delete pods,services -l name=myLabel --include-uninitialized      # 删除具有 name=myLabel 标签的 pod 和 service，包括尚未初始化的
$ kubectl -n my-ns delete po,svc --all                                      # 删除 my-ns namespace 下的所有 pod 和 serivce，包括尚未初始化的
```

## 与运行中的 Pod 交互

```bash
$ kubectl logs my-pod                                 # dump 输出 pod 的日志（stdout）
$ kubectl logs my-pod -c my-container                 # dump 输出 pod 中容器的日志（stdout，pod 中有多个容器的情况下使用）
$ kubectl logs -f my-pod                              # 流式输出 pod 的日志（stdout）
$ kubectl logs -f my-pod -c my-container              # 流式输出 pod 中容器的日志（stdout，pod 中有多个容器的情况下使用）
$ kubectl run -i --tty busybox --image=busybox -- sh  # 交互式 shell 的方式运行 pod
$ kubectl attach my-pod -i                            # 连接到运行中的容器
$ kubectl port-forward my-pod 5000:6000               # 转发 pod 中的 6000 端口到本地的 5000 端口
$ kubectl exec my-pod -- ls /                         # 在已存在的容器中执行命令（只有一个容器的情况下）
$ kubectl exec my-pod -c my-container -- ls /         # 在已存在的容器中执行命令（pod 中有多个容器的情况下）
$ kubectl top pod POD_NAME --containers               # 显示指定 pod 和容器的指标度量
```

## 与节点和集群交互

```bash
$ kubectl cordon my-node                                                # 标记 my-node 不可调度
$ kubectl drain my-node                                                 # 清空 my-node 以待维护
$ kubectl uncordon my-node                                              # 标记 my-node 可调度
$ kubectl top node my-node                                              # 显示 my-node 的指标度量
$ kubectl cluster-info                                                  # 显示 master 和服务的地址
$ kubectl cluster-info dump                                             # 将当前集群状态输出到 stdout                                    
$ kubectl cluster-info dump --output-directory=/path/to/cluster-state   # 将当前集群状态输出到 /path/to/cluster-state

# 如果该键和影响的污点（taint）已存在，则使用指定的值替换
$ kubectl taint nodes foo dedicated=special-user:NoSchedule
```

## 资源类型

下表列出的是 kubernetes 中所有支持的类型和缩写的别名。

| 资源类型                       | 缩写别名     |
| -------------------------- | -------- |
| `clusters`                 |          |
| `componentstatuses`        | `cs`     |
| `configmaps`               | `cm`     |
| `daemonsets`               | `ds`     |
| `deployments`              | `deploy` |
| `endpoints`                | `ep`     |
| `event`                    | `ev`     |
| `horizontalpodautoscalers` | `hpa`    |
| `ingresses`                | `ing`    |
| `jobs`                     |          |
| `limitranges`              | `limits` |
| `namespaces`               | `ns`     |
| `networkpolicies`          |          |
| `nodes`                    | `no`     |
| `statefulsets`             |          |
| `persistentvolumeclaims`   | `pvc`    |
| `persistentvolumes`        | `pv`     |
| `pods`                     | `po`     |
| `podsecuritypolicies`      | `psp`    |
| `podtemplates`             |          |
| `replicasets`              | `rs`     |
| `replicationcontrollers`   | `rc`     |
| `resourcequotas`           | `quota`  |
| `cronjob`                  |          |
| `secrets`                  |          |
| `serviceaccount`           | `sa`     |
| `services`                 | `svc`    |
| `storageclasses`           |          |
| `thirdpartyresources`      |          |

### 格式化输出

要以特定的格式向终端窗口输出详细信息，可以在 `kubectl` 命令中添加 `-o` 或者 `-output` 标志。

| 输出格式                                | 描述                                       |
| ----------------------------------- | ---------------------------------------- |
| `-o=custom-columns=<spec>`          | 使用逗号分隔的自定义列列表打印表格                        |
| `-o=custom-columns-file=<filename>` | 使用 文件中的自定义列模板打印表格                        |
| `-o=json`                           | 输出 JSON 格式的 API 对象                       |
| `-o=jsonpath=<template>`            | 打印 [jsonpath](https://kubernetes.io/docs/user-guide/jsonpath) 表达式中定义的字段 |
| `-o=jsonpath-file=<filename>`       | 打印由 文件中的 [jsonpath](https://kubernetes.io/docs/user-guide/jsonpath) 表达式定义的字段 |
| `-o=name`                           | 仅打印资源名称                                  |
| `-o=wide`                           | 以纯文本格式输出任何附加信息，对于 Pod ，包含节点名称            |
| `-o=yaml`                           | 输出 YAML 格式的 API 对象                       |

### Kubectl 详细输出和调试

使用 `-v` 或 `--v` 标志跟着一个整数来指定日志级别。

| 详细等级    | 描述                                       |
| ------- | ---------------------------------------- |
| `--v=0` | 总是对操作人员可见。                               |
| `--v=1` | 合理的默认日志级别，如果您不需要详细输出。                    |
| `--v=2` | 可能与系统的重大变化相关的，有关稳定状态的信息和重要的日志信息。这是对大多数系统推荐的日志级别。 |
| `--v=3` | 有关更改的扩展信息。                               |
| `--v=4` | 调试级别详细输出。                                |
| `--v=6` | 显示请求的资源。                                 |
| `--v=7` | 显示HTTP请求的header。                         |
| `--v=8` | 显示HTTP请求的内容。                             |


## 补充

1. 查看pod详细信息

```
kubectl -n backend get  pod/myapp-7b9f486cf9-9rfpg -o wide
```

2. 查看pod描述

```
kubectl -n backend describe myapp-7b9f486cf9-9rfpg
```


3. 进入 pod 内的容器：

```
kubectl -n backend  exec -it myapp-7b9f486cf9-9rfpg -c filebeat-myapp -- bash
```

> 双横杠（--）代表 kubectl 命令项的结束，在双横杠后面的内容是指pod内部需要执行的命令。


## kubectl CLI

1. `cluster-info`  查看当前集群的一些信息 , `version`查看集群版本信息等
``` 	
	kubectl version    
	kubectl cluster-info
``` 

1. `run` 在容器内执行一条shell命令,类似于 docker exec。如果一个pod容器中，有多个容器，需要使用-c选项指定容器。 
```  
	kubectl run
	kubectl run --image=nginx:alpine nginx-app --port=80
```    

1. `get`  查询资源列表,类似于docker ps  
	- 获取资源信息
	``` 	
		kubectl get  	
		kubectl get nodes
		kubectl get service
		kubectl get deployment
		kubectl get pod
		kubectl get replicaset		
		kubectl get namespace		
	``` 
	- 获取pod运行在哪个节点上的信息 
	``` 	
		kubectl get pod -o wide
		kubectl get pods --namespace=<namespace_name>
	``` 
	- 获取namespace信息
	``` 
		kubectl get namespace
	``` 
	- 输出pod的详细信息,使用选项“-o”	
	``` 
		#以yaml格式输出pod的详细信息。
		kubectl get pod <podname> -o yaml 
		#以json格式输出pod的详细信息。	
		kubectl get pod <podname> -o json 
		
		#使用”-o=custom-columns=“定义直接获取指定内容的值。
		#其中LABELS为显示的列标题，”.metadata.labels.app”为查询的域名 
		kubectl get po nginx-app-7699ff5576-d8qtk -o=custom-columns=LABELS:.metadata.labels.app

		#以yaml格式输出service的详细信息。
		kubectl get svc <service_name> -o yaml
	``` 
各种资源名称及其简写见 [resource_name.md](./resource_name.md)

1. `create` 定义了相应resource的yaml或son文件，直接kubectl create -f filename即可创建文件内定义的resource
``` 
    kubectl create -f rc-nginx.yaml
``` 

1. `describe` 获取资源的详细信息,类似于 docker inspect  
``` 
    kubectl describe

	kubectl describe pod nginx-app-7699ff5576-d8qtk
	kubectl describe node node1
``` 

1. `logs` 获取容器的日志,类似于 docker logs，如果要获得tail -f 的方式，也可以使用-f选项。 
 ``` 
    kubectl logs
    kubectl logs nginx-app-7699ff5576-d8qtk
``` 

1. `exec` 在容器内执行一个命令,类似于 docker exec  
```    
kubectl exec     
kubectl exec nginx-app-7699ff5576-d8qtk ps aux
```  

1. `replace` 命令用于对已有资源进行更新、替换。如前面create中创建的nginx,可以直接修改原yaml文件，然后执行replace命令。 
``` 
	kubectl replace -f rc-nginx.yaml 
``` 

1. `patch` :一个容器已经在运行，这时需要对一些容器属性进行修改，又不想删除容器，或不方便通过replace的方式进行更新。使用 `patch` 直接对容器进行修改的方式
```    
	# 前面创建pod的label是app=nginx-2，如果在运行过程中，需要把其label改为app=nginx-3``` 
	kubectl patch pod rc-nginx-2-kpiqt -p '{"metadata":{"labels":{"app":"nginx-3"}}}' 
```   

1. `edit` 直接更新前面创建的pod
``` 
	kubectl edit po rc-nginx-btv4j

    # 效果等效于  
	kubectl get po rc-nginx-btv4j -o yaml &gt;&gt; /tmp/nginx-tmp.yaml  
	vim /tmp/nginx-tmp.yaml   
	/*do some changes here */  
	kubectl replace -f /tmp/nginx-tmp.yaml  
``` 

1. `Delete`  根据resource名或label删除resource
```     
kubectl delete -f rc-nginx.yaml  
kubectl delete pod rc-nginx-btv4j  
kubectl delete pod -lapp=nginx-2 
kubectl delete servie kubernetes-bootcamp  #删除服务
``` 

1. `apply` 提供了比patch，edit等更严格的更新resource的方式。apply命令的使用方式同replace相同，但不同的是，apply不删除原有resource创建新的。而直接在原有resource的基础上进行更新。同时kubectl apply还会resource中添加一条注释，标记当前的apply。类似于git操作.

1. `rolling-update` 对于已经部署并且正在运行的业务，rolling-update提供了不中断业务的更新方式。rolling-update每次起一个新的pod，等新pod完全起来后删除一个旧的pod，然后再起一个新的pod替换旧的pod，直到替换掉所有的pod。rolling-update需要确保新的版本有不同的name，Version和label，否则会报错。
``` 
kubectl rolling-update rc-nginx-2 -f rc-nginx.yaml 
```    

	如果在升级过程中，发现有问题还可以中途停止update，并回滚到前面版本 
	``` 
	kubectl rolling-update rc-nginx-2 —rollback 
	``` 

1. `scale` 用于程序在负载加重或缩小时副本进行扩容或缩小，如前面创建的nginx有两个副本，可以轻松的使用scale命令对副本数进行扩展或缩小。   
	扩展副本数到4：
	``` 
	kubectl scale rc rc-nginx-3 —replicas=4 
	```     
	重新缩减副本数到2
	``` 
	kubectl scale rc rc-nginx-3 —replicas=2 
	``` 

1. `autoscale` 命令会给一个rc指定一个副本数的范围，在实际运行中根据pod中运行的程序的负载自动在指定的范围内对pod进行扩容或缩容。
	如前面创建的nginx，可以用如下命令指定副本范围在
1.4 
``` 
    kubectl autoscale rc rc-nginx-3 --min=1 max=4 
``` 		
	以下命令定义一个自动水平扩容（HPA）资源对象的的方式,扩容时副本数在
1.
1.之间， pod 的 CPU 利用率超过 90% 即触发自动扩容创建新的副本。
``` 
	kubectl autoscale deployment php-apache --cpu-percent=90 --min=1 --max=2
``` 

1. `attach` 类似于docker的attach命令。可以直接查看容器中以daemon形式运行的进程的输出，效果类似于logs -f，退出查看使用ctrl-c。  
	如果一个pod中有多个容器，要查看具体的某个容器的的输出，需要在pod名后使用-c containers name指定运行的容器。
	如下示例的命令为查看kube-system namespace中的kube-dns-v9-rcfuk pod中的skydns容器的输出。 
```     
    kubectl attach kube-dns-v9-rcfuk -c skydns --namespace=kube-system    
```   

1. `port-forward`  转发一个本地端口到容器端口，一般都是使用yaml的方式编排容器，所以基本不使用此命令。 

1. `label` 更新资源对象的标签
给 Pod “nginx-ds-2frsh” 添加一个标签 role=frontend
```
kubectl label pod nginx-ds-2frsh role=frontend	
```
查看 Pod 的 Label
```
[k8s@node04 ~]$ kubectl get pod -Lrole
NAME                        READY     STATUS    RESTARTS   AGE       ROLE   
mysql                       1/1       Running   2          15d       
nginx-ds-2frsh              1/1       Running   8          27d       frontend
```
修改一个Lable,需加上 `--overwrite` 参数
```
kubectl label pod nginx-ds-2frsh role=frontend2 --overwrite
```
删除一个Lable,指定Label的Key名并与一个减号相连
```
kubectl label pod nginx-ds-2frsh role-
```

1. `cordon` Node的隔离与恢复
将 node06隔离,新Pod不在往 node06 上调度(node06已有的pod不会终止)
```
kubectl cordon node06
```
查看结果
```
[k8s@node04 ~]$ kubectl get node
NAME      STATUS                     ROLES     AGE       VERSION
node04    Ready                      <none>    27d       v1.10.4
node05    Ready                      <none>    27d       v1.10.4
node06    Ready,SchedulingDisabled   <none>    27d       v1.10.4
```
将 node06 取消隔离
```
kubectl cordon node06
```



## 参考

- [Kubectl 概览](https://kubernetes.io/docs/user-guide/kubectl-overview)
- [JsonPath 手册](https://kubernetes.io/docs/user-guide/jsonpath)

