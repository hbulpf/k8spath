**Kubernetes使用NFS作为共享存储**

kubernetes管理的容器是封装的，有时候我们需要将容器运行的日志，放到本地来或是共享存储来，以防止容器宕掉，日志还在还可以分析问题。kubernetes的共享存储方案目前比较流行的一般是三个，分别是：nfs，Glusterfs和ceph。
kubernetes使用nfs作为共享存储

## 一. 创建 NFS 服务器

NFS 允许系统将其目录和文件共享给网络上的其他系统。通过 NFS，用户和应用程序可以访问远程系统上的文件，就象它们是本地文件一样。

1、CentOS 7.x 安装NFS服务器：
```
yum -y install nfs
```
2、配置

编辑 `/etc/exports` 文件添加需要共享目录，每个目录的设置独占一行，编写格式如下：
```
NFS共享目录路径 客户机IP或者名称(参数1,参数2,...,参数n)
```

例如：

```
/home *(ro,sync,insecure,no_root_squash)
/data/nginx 192.168.1.*(rw,sync,insecure,no_subtree_check,no_root_squash)
```
```
参数  说明
ro  只读访问
rw  读写访问
sync    所有数据在请求时写入共享
async   nfs在写入数据前可以响应请求
secure  nfs通过1024以下的安全TCP/IP端口发送
insecure    nfs通过1024以上的端口发送
wdelay  如果多个用户要写入nfs目录，则归组写入（默认）
no_wdelay   如果多个用户要写入nfs目录，则立即写入，当使用async时，无需此设置
hide    在nfs共享目录中不共享其子目录
no_hide 共享nfs目录的子目录
subtree_check   如果共享/usr/bin之类的子目录时，强制nfs检查父目录的权限（默认）
no_subtree_check    不检查父目录权限
all_squash  共享文件的UID和GID映射匿名用户anonymous，适合公用目录
no_all_squash   保留共享文件的UID和GID（默认）
root_squash root用户的所有请求映射成如anonymous用户一样的权限（默认）
no_root_squash  root用户具有根目录的完全管理访问权限
anonuid=xxx 指定nfs服务器/etc/passwd文件中匿名用户的UID
anongid=xxx 指定nfs服务器/etc/passwd文件中匿名用户的GID
注1：尽量指定主机名或IP或IP段最小化授权可以访问NFS 挂载的资源的客户端
注2：经测试参数insecure必须要加，否则客户端挂载出错mount.nfs: access denied by server while mounting
```
3、启动

配置完成后，您可以在终端提示符后运行以下命令来启动 NFS 服务器：
```
systemctl start nfs.service
```
4、客户端挂载

CentOS 7, 需要安装 nfs-utils 包
```
yum install nfs-utils
```
使用 mount 命令来挂载其他机器共享的 NFS 目录。可以在终端提示符后输入以下类似的命令：
```
mount 192.168.200.25:/data/k8s /data/k8s25
```
挂载点/mnt 目录必须已经存在。而且在 /mnt目录中没有文件或子目录。

另一个永久性挂载NFS 共享的方式就是在 /etc/fstab 文件中添加一行。该行必须指明 NFS 服务器的主机名、服务器输出的目录名以及挂载 NFS 共享的本机目录。

以下是在 /etc/fstab 中的常用语法：
```
192.168.200.25:/data/k8s /data/k8s25 nfs rsize=8192,wsize=8192,timeo=14,intr
```

## 二、Kubernetes上部署一个应用nginx使用nfs共享存储
在 kubernetes 主节点上，创建命名空间
``` 
##创建namespaces
apiVersion: v1
kind: Namespace
metadata:
   name: nfs-test
   labels:
     name: nfs-nfs-test
```  

创建 nfs 的yaml文件:nfs-nginx.yaml
```  
##创建nfs-PV
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-pv
  namespace: nfs-test
  labels:
    pv: nfs-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  nfs:
    path: /data/k8s
    server: 192.168.200.25
##创建 NFS-pvc
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: nfs-pvc
  namespace: nfs-test
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
  selector:
    matchLabels:
      pv: nfs-pv
## 部署应用Nginx
---
apiVersion: v1
kind: ReplicationController
metadata:
  name: nginx-nfs-test
  labels:
    name: nginx-nfs-test
  namespace: nfs-test
spec:
  replicas: 2
  selector:
    name: nginx-nfs-test
  template:
    metadata:
      labels: 
       name: nginx-nfs-test
    spec:
      containers:
      - name: nginx-nfs-test
        image: docker.io/nginx
        volumeMounts:
        - mountPath: /usr/share/nginx/html
          name: nginx-data
        ports:
        - containerPort: 80
      volumes:
      - name: nginx-data
        persistentVolumeClaim:
          claimName: nfs-pvc
##创建Service
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-nfs-test
  labels: 
   name: nginx-nfs-test
  namespace: nfs-test
spec:
  type: NodePort
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
    name: http
    nodePort: 8480
  selector:
    name: nginx-nfs-test
```  

```  
[root@qa-k8s-master-01 ]# kubectl create -f ns.yaml 
namespace/nfs-test created
[root@qa-k8s-master-01 ]# kubectl create -f nfs-nginx.yaml 
persistentvolume/nfs-pv created
persistentvolumeclaim/nfs-pvc created
replicationcontroller/nginx-test created
service/nginx-test created
[root@qa-k8s-master-01 ~]# kubectl get pod -n test
NAME               READY     STATUS    RESTARTS   AGE
nginx-test-ssbnr   1/1       Running   0          4m
nginx-test-zl7vk   1/1       Running   0          4m
[root@qa-k8s-master-01 ~]# kubectl get service -n test
NAME         TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
nginx-test   NodePort   10.68.145.112   <none>        80:20080/TCP   5m
```  
可以看到，nginx应用已经部署成功。

nginx应用的数据目录是使用的nfs共享存储，我们在nfs共享的目录里加入index.html文件，然后再访问nginx-service 暴露的端口

在nfs服务器上
```  
[root@harbor ~]# echo "Test NFS Share discovery" > /data/k8s/nginx/index.html
```  
在浏览器上访问kubernetes主节点的ip：8480 就能看到上面的内容

## 其他
1. 如果 pod 一直挂载不成功，报错误
```
MountVolume.SetUp failed for volume "nfs-pv" : mount failed: exit status 32 Mounting command: systemd-run Mounting arguments: --description=Kubernetes transient mount for /var/lib/kubelet/pods/ec72ea12-40d8-11e9-9409-080027d20dce/volumes/kubernetes.io~nfs/nfs-pv --scope -- mount -t nfs 192.168.200.25:/data/k8s /var/lib/kubelet/pods/ec72ea12-40d8-11e9-9409-080027d20dce/volumes/kubernetes.io~nfs/nfs-pv Output: Running scope as unit run-27199.scope. mount: wrong fs type, bad option, bad superblock on 192.168.200.25:/data/k8s, missing codepage or helper program, or other error (for several filesystems (e.g. nfs, cifs) you might need a /sbin/mount.<type> helper program) In some cases useful info is found in syslog - try dmesg | tail or so.
```
在kubernetes所有 Worker 节点上安装 `nfs-utils`
```
yum install nfs-utils
```


# 参考
1. Kubernetes使用NFS作为共享存储 . https://blog.51cto.com/passed/2160149?source=dra
1. kubernetes使用GlusterFS的文章 . https://blog.51cto.com/passed/2139299