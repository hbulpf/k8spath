### 1. 容器内 `apt-get update` 出现 ` Could not resolve 'security.debian.org'` 错误

修改 容器的 `/etc/resolv.conf` 内容为正确的 dns 服务器后没有效果。按照如下解决步骤：

1. 找出宿主机的dns： `cat /etc/resolv.conf` 。一般是两个，例如: 10.0.0.2, 10.0.0.3；
2. 编辑  `/etc/docker/daemon.json` 文件（该文件不存在，需新建），输入内容：
```
{                                                                          
"dns": ["10.0.0.2", "10.0.0.3"]
}    
```
3. 重启docker服务：`systemctl restart docker` 此条命令将会关掉所有的容器

### 1. 容器启动时不能转发Ipv4
报错 `WARNING: IPv4 forwarding is disabled. Networking will not work.`

【解决】
执行以下代码
```
#配置转发
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
#重启网络服务，让配置生效
systemctl restart network 
#查看是否成功,如果返回为“net.ipv4.ip_forward = 1”则表示成功
sysctl net.ipv4.ip_forward
```
然后重启需要做端口映射的容器