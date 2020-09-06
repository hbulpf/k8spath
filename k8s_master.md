# Master节点
1. k8s master节点作为　Worker Node 使用
	出于安全考虑，默认配置下 Kubernetes 不会将 Pod 调度到 Master 节点。如果希望将 k8s-master 也当作 Node 使用，执行如下命令：
	```
	kubectl taint node k8s-master node-role.kubernetes.io/master-
	```
	如果要恢复 Master Only 状态，执行如下命令：
	```
	kubectl taint node k8s-master node-role.kubernetes.io/master="":NoSchedule
	```
1. 标注 k8s-node1 是配置了 SSD 的节点
	```
	kubectl label node 172.31.21.32 disktype=ssd
	```
	查看节点的 label
	```
	kubectl get node --show-labels
	```
	删除节点的label
	```
	kubectl label node 172.31.21.32 disktype-
	```

	```
	[root@ip-172-31-24-224 opt]# kubectl label node 172.31.21.32 disktype=ssd
	node "172.31.21.32" labeled
	[root@ip-172-31-24-224 opt]# kubectl get node --show-labels
	NAME            STATUS    ROLES     AGE       VERSION   LABELS
	172.31.21.32    Ready     <none>    9d        v1.10.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,disktype=ssd,kubernetes.io/hostname=172.31.21.32
	172.31.24.224   Ready     <none>    9d        v1.10.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=172.31.24.224
	172.31.25.125   Ready     <none>    9d        v1.10.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=172.31.25.125
	[root@ip-172-31-24-224 opt]# kubectl label node 172.31.21.32 disktype-
	node "172.31.21.32" labeled
	```	

1. 使用 节点的 label 来部署 pod  
	`nginx_label.yml` 如下
	```
	apiVersion: extensions/v1beta1
	kind: Deployment 
	metadata: 
	  name: nginx-deployment3
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
	      nodeSelector:
	        disktype: ssd
	```

	nginx-deployment3 的pod都部署在 `172.31.21.32` 上：
	```
	[root@ip-172-31-24-224 opt]# kubectl apply -f nginx_label.yml 
	deployment.extensions "nginx-deployment3" created
	[root@ip-172-31-24-224 opt]# kubectl get pod -o wide | grep nginx-deployment3
	nginx-deployment3-8458b87767-2c42f   1/1       Running   0          14m       172.17.0.6   172.31.21.32
	nginx-deployment3-8458b87767-nh26j   1/1       Running   0          14m       172.17.0.5   172.31.21.32
	```	