# 运行 tomcat
## 创建RC
[myweb-rc.yaml](./myweb-rc.yaml)如下:
```
kind: ReplicationController
metadata:
  name: myweb
spec:
  replicas: 2
  selector:
    app: myweb
  template:
    metadata:
      labels:
        app: myweb
    spec:
      containers:
        - name: myweb
          image: kubeguide/tomcat-app:v1
          ports:
          - containerPort: 8080
          env:
          - name: MYSQL_SERVICE_HOST
            value: "mysql"
          - name: MYSQL_SERVICE_PORT
            value: "3306"      
```

运行
```
kubectl create -f ./myweb-rc.yaml 
kubectl get pod
```

## 创建 SVC
[myweb-svc.yaml](./myweb-svc.yaml)如下:
```
apiVersion: v1
kind: Service
metadata:
  name: myweb
spec:
  type: NodePort
  ports:
  - port: 8080
    nodePort: 30001
  selector:
    app: myweb
```

运行
```
kubectl create -f ./myweb-svc.yaml 
kubectl get svc
curl http://localhost:30001/demo/  # 验证应用是否部署
```

# 参考
