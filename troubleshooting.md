## kubernetes Issues Shooting


1. 在《kubernetes权威指南》入门的一个例子中，发现pod一直处于ContainerCreating的状态，用kubectl describe pod mysql的时候发现如下报错,解决：
[https://blog.csdn.net/qq_28451255/article/details/80491025](https://blog.csdn.net/qq_28451255/article/details/80491025)


1. Kubernetes之 YAML 文件简介: [https://blog.csdn.net/phantom_111/article/details/79427144](https://blog.csdn.net/phantom_111/article/details/79427144)  
	

	在线 **YAML** 文件解析：[http://nodeca.github.io/js-yaml/](http://nodeca.github.io/js-yaml/)  

	**Replication Controller 文件范例**

	
	> 	kind: ReplicationController  
	> 	metadata:  
	> 	  name: myweb  
	> 	spec:  
	> 	  replicas: 2  
	> 	  selector:  
	> 	    app: myweb  
	> 	  template:  
	> 	     metadata:  
	> 	      labels:  
	> 	        app: myweb  
	> 	     spec:  
	> 	      containers:  
	> 	         - name: myweb  
	> 	           image: tomcat  
	> 	           ports:  
	> 	           - containerPort: 8080  
	> 	           env:  
	> 	           - name: MYSQL_SERVICE_HOST  
	> 	             value: "mysql"  
	> 	           - name: MYSQL_SERVICE_PORT  
	> 	             value: "3306"       
 	
	
	**service 文件范例**

	> 	apiVersion: v1  
	> 	kind: Service  
	> 	metadata:  
	> 	 name: myweb  
	> 	spec:  
	> 	 type: NodePort  
	> 	 ports:  
	> 	  - port: 3306  
	> 	    nodePort: 30001  
	> 	 selector:  
	> 	  app: myweb  

  1. Ingress
  https://blog.csdn.net/aixiaoyang168/article/details/78485581?locationNum=5&fps=1  