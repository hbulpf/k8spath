# Kubernetes 笔记

## Kubernetes 解决方案
1. Service 服务进程都是基于Socket通信方式对外提供服务。
2. Pod 对象将一个运行的容器包装起来，实现隔离，Service 和 Pod 通过 Label 关联。
3. Kubernetes 在集群管理方面有：资源管理、Pod 调度、弹性伸缩、安全控制、系统监控和纠错等管理功能。
4. Service 扩容: 只需要创建一个 Replication Controller.

### Kubernetes 各组件

### Kubernetes 概念术语
##### Master
##### Node
在 k8s 早期版本中，Node 叫做 Minion
##### Pod
##### Label
##### Replication Controller (RC)
在RC中只需要定义3个关键信息：

+ 目标 Pod 的定义
+ 目标 Pod 需要的副本数（Replicas）
+ 要监控的目标 Pod 的标签（Label）

在 k8s 1.2 以后的版本，Replication Controller 叫 Replica Set 
```
kubectl scale rc redis-slave --replicas=3
```

##### Deployment
Deployment 内部使用 Replica Set 来实现。但与 Replica Set 的区别在于可以随时知道当前Pod部署的进度。

Deployment的典型使用场景：
1. 创建一个 Deployment 对象来生成对应的 Replica Set 并完成 Pod 副本的创建过程
2. 检查 Deployment 的状态来看 Pod 副本的数量是否达到预期的值。
3. 更新 Deployment 以创建新的 Pod
4. 如果当前 Deployment 不稳定，则回滚到一个早先的 Deployment 版本。
5. 挂起或恢复一个 Deployment。

##### Horizontal Pod AutoScaler (HPA)
HPA 对 Pod 负载的度量指标：
1. CPU UtilizationPercentage : 目标 Pod 所有副本自身的CPU利用率的平均值
2. 应用程序自定义的度量指标，比如服务在每秒内的相应请求数(TPS 或 QPS)。

##### Service
3种IP:
+ Node IP
+ Pod IP
+ Cluster IP

裸机负载均衡: Bare Metal Service Load Balancers

##### Volume
##### Persistent Volume
##### Namespace
##### Annotation

#### DaemonSet
#### Job

# Kubernetes 开发
1. [fabric8](https://github.com/fabric8io/kubernetes-client)

# Kubernetes 运维
### 资源限额
1. LimitRange : 容器和Pod的Request和Limits
2. ResourceQuota : 在 NameSpace 上进行限额
3. Scope 使得资源配额只对特定范围的对象加以限制。

## 获取数据
1. 使用 cAdvisor获取数据: http://192.168.56.104:4194/api/v1.3/machine

资源调度
弹性伸缩、自动扩展
资源高利用率
负载均衡
资源基本监控
容灾备份
滚动更新
日志访问
自检和自愈


4.devops流水线设计
根据上面的介绍，经过一定积累和沉淀后，我们开始设计CI（持续集成），CD（自动化部署），CI/CD的优势显而易见
- 解放了重复性劳动：
- 自动化部署工作可以解放集成、测试、部署等重复性劳动，而机器集成的频率明显比手工高很多。
- 更快地修复问题：持续集成更早的获取变更，更早的进入测试，更早的发现问题，解决问题的成本显著下降。
- 更快的交付成果：更早发现错误减少解决错误所需的工作量。集成服务器在构建环节发现错误可以及时通知开发人员修复。集成服务器在部署环节发现错误可以回退到上一版本，服务器始终有一个可用的版本。
- 减少手工的错误：在重复性动作上，人容易犯错，而机器犯错的几率几乎为零。
- 减少了等待时间：缩短了从开发、集成、测试、部署各个环节的时间，从而也就缩短了中间可以出现的等待时机。持续集成，意味着开发、集成、测试、部署也得以持续。