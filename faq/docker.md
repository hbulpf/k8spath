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