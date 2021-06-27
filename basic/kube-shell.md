# kube-shell

Kube-shell是基于python-prompt-toolkit实现的，旨在提供Kubectl的易用性并提高生产力。kube-shell提供如下功能：

* 自动完成kubectl命令及参数提示
* 颜色标示显示
* 历史命令自动填充
* 模糊查询，服务端自动完成
* 上下文信息及切换，F4切换集群，F5切换Namespaces

## 1、环境准备
### 1.1 python2.7.5升级到2.7.14
查看Python版本
```
[root@os161 /]# python -V
Python 2.7.5
```
下载python2.7.14
```
[root@os161 /]# wget https://www.python.org/ftp/python/2.7.14/Python-2.7.14.tgz
--2018-01-19 17:06:49--  https://www.python.org/ftp/python/2.7.14/Python-2.7.14.tgz
正在解析主机 www.python.org (www.python.org)... 151.101.228.223, 2a04:4e42:36::223
正在连接 www.python.org (www.python.org)|151.101.228.223|:443... 已连接。
已发出 HTTP 请求，正在等待回应... 200 OK
长度：17176758 (16M) [application/octet-stream]
正在保存至: “Python-2.7.14.tgz”

 0% [ 
 ```
解压Python包
```
tar -zxvf Python-2.7.13.tgz
```
检查&准备编译环境
```
yum install gcc* openssl openssl-devel ncurses-devel.x86_64  bzip2-devel sqlite-devel python-devel zlib
```
安装
```
cd Python-2.7.14
./configure --prefix=/usr/local
make && make altinstall 
```
备份旧版，yum等组件依赖于2.7.5工作
```
mv /usr/bin/python /usr/bin/python2.7.5
ln -s /usr/local/bin/python2.7 /usr/bin/python 
```
验证
```
[root@os163 Python-2.7.14]# python -V
Python 2.7.14
[root@os163 Python-2.7.14]# python2.7.5 -V
Python 2.7.5
```
修正yum等组件python
```
[root@localhost bin]# vim /usr/bin/yum
首行的#!/usr/bin/python 改为 #!/usr/bin/python2.7.5
[root@localhost bin]# vim /usr/libexec/urlgrabber-ext-down
首行的#!/usr/bin/python 改为 #!/usr/bin/python2.7.5
```
### 1.2 Pip安装
```
wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py
ln -s /usr/local/bin/pip2.7 /usr/bin/pip   
```
**不要试用如下方式安装pip会出现不工作 !**
```
sudo yum -y install epel-release 
sudo yum -y install python-pip
```
## 2、kube-shell 安装
```
pip install kube-shell
```
## 3、验证及使用
```
[root@os163 Python-2.7.14]# kube-shell
kube-shell> kubectl get clusterrole -n kube-system
               kubectl  kubectl controls the Kubernetes cluster manager  

 [F4] Cluster: kubernetes [F5] Namespace: default User: kubernetes-admin [F9] In-line help: ON [F10] Exit  
```

# 参考
1. centos 安装kube-shell . https://my.oschina.net/neverforget/blog/1609780
