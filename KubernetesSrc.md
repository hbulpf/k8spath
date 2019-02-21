Kubernetes 源码解析

### Kubernetes 源码结构
#### 源码目录
```
.
├── api
├── build
├── cluster
├── cmd  所有后台进程的代码
├── docs
├── Godeps
├── hack
├── logo
├── pkg  主体代码
├── plugin  插件
├── staging
├── test  测试代码
├── third_party
├── translations
└── vendor
```

#### pkg主体代码结构
pkg中包含了Kubernetes 的主体源码[[1]](#参考1)，具体结构如下：

package | 模块用途 
------- | ---------
api  | Kubernetes 提供的RestAPI 接口的相关类
apis  | 实现 HTTP Rest 服务的一个基础性框架，用于 Kubernetes 的各种 RestAPI 的实现
auth | 3A认证模块，包括用户认证、鉴权相关组件
client |
cloudprovider | 
controller | 
kubectl | 
kubelet | 
master | Kubernetes 的 Master 节点代码模块，创建 NodeRegistry 、PodRestry 、ServiceRegistry 、EndpointRegistry 等组件，并启动 Kubernetes 自身的相关服务，服务的ClusterIP地址分配及服务的NodePort端口分配等。
proxy |
registry |
volume | 

### 引入的第三方框架
1. go-restful 框架 . https://github.com/emicklei/go-restful

# 参考
1. 龚正,吴治辉等 . Kubernetes权威指南:从Docker到Kubernetes全接触[M] . 北京：电子工业出版社,2016:398-399
