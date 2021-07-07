# pod各种异常状态定位

一般可以通过kubectl get pod和kubectl describe pod命令得到pod异常状态原因

（1）Terminating：

有状态应用，应该先启动的pod没有启动，导致后启动的pod termainating

（2）Running(0/1)

pod状态正常，但是pod内的容器状态不正常，0/1表示pod有1个容器但是只有0个容器正常运行（2/3同理表示3个容器中至于2个容器正常运行，1个容器状态异常），该状态表示有容器运行不正常，kubectl describe pod可以根据event事件看到容器状态异常原因，event事件只会保存2小时，另外可以到该pod所在的节点上查看kubelet日志/var/log/sys/pass/kubernetes/kubelet.log，找到对应时间点查看容器的运行日志也可以定位到容器异常原因，容易异常原因有：节点重启、容器的健康检查失败、容器所在节点的docker或者canal组件异常等原因；

（3）ContainerCreating

应用刚部署时会出现该状态，之后会恢复至Running；

pod所在的节点的docker thin pool镜像空间不够，导致pod的容器因为无法加载镜像不能启动，会出现该状态，把当前节点的docker冗余镜像删除即可恢复；

pod所在节点本地没有相应的镜像，导致容器启动不起来，会出现该异常状态；

（4）ExecuteCommandFailed

容器启动时，容器配置文件里的执行脚本执行失败导致；

（5）ImagePullBackOff

拉取镜像时ak/sk鉴权失败

（6）ErrPackagePull

镜像拉取失败导致，访问不了镜像仓库或者镜像仓库没有该镜像；

（7）CrashLoopBackOff

liviness probe failed，或者readiness probe failed，健康检查脚本/启动检查脚本执行失败，负责该pod的接口人排查；

（8）Pending

pod调度失败会出现该状态，由于不符合调度规则比如不符合节点标签、不符合亲和/反亲和规则、节点cpu/内存不符合要求、节点状态不正常等等；

（9）CreateContainerError

pod内容器创建时出现错误，kube-apiserver连不上会出现该状态；
