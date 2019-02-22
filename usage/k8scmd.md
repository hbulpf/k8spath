# Kuberntes手册
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

