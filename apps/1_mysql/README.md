# 运行 MySQL
## 安装 K8S
代码见[k8s.sh](./k8s.sh)
```
systemctl disable firewalld
systemctl stop firewalld
yum install -y etcd kubernetes

vim /etc/sysconfig/docker
#/etc/sysconfig/docker中OPTIONS的内容改为
#OPTIONS='--selinux-enabled=false --insecure-registry gcr.io'
vim /etc/kubernetes/apiserver
#vim /etc/kubernetes/apiserver
#去掉--admission_control参数中的ServiceAccount

systemctl enable etcd
systemctl enable docker
systemctl enable kube-apiserver
systemctl enable kube-controller-manager
systemctl enable kube-scheduler
systemctl enable kubelet
systemctl enable kube-proxy

systemctl start etcd
systemctl start docker
systemctl start kube-apiserver
systemctl start kube-controller-manager
systemctl start kube-scheduler
systemctl start kubelet
systemctl start kube-proxy
```


若 pod 状态一直处在 `ContainerCreating` , 查看容器详细信息时报 `/etc/docker/certs.d/registry.access.redhat.com/redhat-ca.crt: no such file or directory` ，如下
```
[root@node10 1_mysql]# kubectl describe  pod mysql-59swh
......
  2m        1m      4   {kubelet 127.0.0.1}         Warning     FailedSync  Error syncing pod, skipping: failed to "StartContainer" for "POD" with ErrImagePull: "image pull failed for registry.access.redhat.com/rhel7/pod-infrastructure:latest, this may be because there are no credentials on this request.  details: (open /etc/docker/certs.d/registry.access.redhat.com/redhat-ca.crt: no such file or directory)"
```
解决方法为[[1]](http://www.mamicode.com/info-detail-2310522.html):
```
yum install *rhsm* 
wget http://mirror.centos.org/centos/7/os/x86_64/Packages/python-rhsm-certificates-1.19.10-1.el7_4.x86_64.rpm
rpm2cpio python-rhsm-certificates-1.19.10-1.el7_4.x86_64.rpm | cpio -iv --to-stdout ./etc/rhsm/ca/redhat-uep.pem | tee /etc/rhsm/ca/redhat-uep.pem
docker pull registry.access.redhat.com/rhel7/pod-infrastructure:latest
```

## 创建 rc , svc
[mysql-rc.yaml](./mysql-rc.yaml) 如下：
```
apiVersion: v1
kind: ReplicationController
metadata:
  name: mysql
spec:
  replicas: 1
  selector:
    app: mysql
  template:
     metadata:
      labels:
        app: mysql
     spec:
      containers:
        - name: mysql
          image: mysql
          ports:
          - containerPort: 3306
          env:
          - name: MYSQL_ROOT_PASSWORD 
            value: "123456"
```

[mysql-svc.yaml](./mysql-svc.yaml) 如下：
```
apiVersion: v1
kind: Service
metadata:
 name: mysql
spec:
 ports:
  - port: 3306
 selector:
  app: mysql
```

```
kubectl create -f ./mysql-rc.yaml
kubectl get rc
kubectl get pod

kubectl create -f ./mysql-svc.yaml
kubectl get svc
```

# 参考
1. Kubernetes创建pod一直处于ContainerCreating排查和解决 . http://www.mamicode.com/info-detail-2310522.html