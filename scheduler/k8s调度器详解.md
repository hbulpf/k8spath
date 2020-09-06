# Kubernetes调度详解

优良的调度是分布式系统的核心。Scheduler调度器做为Kubernetes三大核心组件之一， 承载着整个集群资源的调度功能，其根据特定调度算法和策略，将Pod调度到最优工作节点上，从而更合理与充分的利用集群计算资源，使资源更好的服务于业务服务的需求。
随着业务服务不断Docker化与微服务化，Kubernetes集群规模不断的扩大，而Kubernetes调度器作为集群的中枢系统，在如何提高集群的底层计算资源利用率、保证集群中服务的稳定运行中也就变得尤为重要。

### 背景介绍

Kubernetes的架构设计基本上是参照了Google Borg。Google的Borg系统群集管理器负责管理几十万个以上的jobs，来自几千个不同的应用，跨多个集群，每个集群有上万个机器。它通过管理控制、高效的任务包装、超售、和进程级别性能隔离实现了高利用率。它支持高可用性应用程序与运行时功能，最大限度地减少故障恢复时间，减少相关故障概率的调度策略。
基于资源分配的任务调度是Kubernetes的核心组件。Kubernetes的调度策略源自Borg, 但是为了更好的适应新一代的容器应用，以及各种规模的部署，Kubernetes的调度策略相应做的更加灵活，也更加容易理解和使用。



默认配置情况下，Kubernetes调度器能够满足绝大多数要求，例如保证Pod只会被分配到资源足够的节点上运行，把同一个集合的Pod分散在不同的计算节点上，平衡不同节点的资源使用率等。

Scheduler是Kubernetes的调度器，其作用是根据特定的调度算法和策略将Pod调度到指定的计算节点（Node）上，其做为单独的程序运行，启动之后会一直监听API Server，获取PodSpec.NodeName为空的Pod，对每个Pod都会创建一个绑定（binding）。




Kubernetes的调度器以插件化形式实现的，方便用户定制和二次开发。用户可以自定义调度器并以插件形式与Kubernetes集成，或集成其他调度器，便于调度不同类型的任务。



上面初步介绍了Kubernetes调度器。具体的说，调度器是Kubernetes容器集群管理系统中加载并运行的调度程序，负责收集、统计分析容器集群管理系统中所有Node的资源使用情况，然后以此为依据将新建的Pod发送到优先级最高的可用Node上去建立。

进一步说：

Priorities阶段是回答“哪个更适合的问题”：即再次对节点进行筛选，筛选出最适合运行Pod的节点。

调度过程的简单图示如下：

[![3.jpg](http://dockone.io/uploads/article/20190714/745e95d0663e2ed9d9ee2dcad9e5ed0e.jpg)](http://dockone.io/uploads/article/20190714/745e95d0663e2ed9d9ee2dcad9e5ed0e.jpg)


具体的调度过程，一般如下：

1. 首先，客户端通过API Server的REST API/kubectl/helm创建pod/service/deployment/job等，支持类型主要为JSON/YAML/helm tgz。
2. 接下来，API Server收到用户请求，存储到相关数据到etcd。
3. 调度器通过API Server查看未调度（bind）的Pod列表，循环遍历地为每个Pod分配节点，尝试为Pod分配节点。调度过程分为2个阶段：
   - 第一阶段：预选过程，过滤节点，调度器用一组规则过滤掉不符合要求的主机。比如Pod指定了所需要的资源量，那么可用资源比Pod需要的资源量少的主机会被过滤掉。
   - 第二阶段：优选过程，节点优先级打分，对第一步筛选出的符合要求的主机进行打分，在主机打分阶段，调度器会考虑一些整体优化策略，比如把容一个Replication Controller的副本分布到不同的主机上，使用最低负载的主机等。
4. 选择主机：选择打分最高的节点，进行binding操作，结果存储到etcd中。
5. 所选节点对于的kubelet根据调度结果执行Pod创建操作。


Kubernetes调度器使用Predicates和Priorites来决定一个Pod应该运行在哪一个节点上。Predicates是强制性规则，用来形容主机匹配Pod所需要的资源，如果没有任何主机满足该Predicates，则该Pod会被挂起，直到有节点能够满足调度条件。



下面分别对Predicates的策略进行介绍：

- NoDiskConflict：pod所需的卷是否和节点已存在的卷冲突。如果节点已经挂载了某个卷，其它同样使用这个卷的pod不能再调度到这个主机上。GCE、Amazon EBS与Ceph RBD的规则如下：

  [![5.jpg](http://dockone.io/uploads/article/20190714/0aac2c03a137b4f1c10ecce16c6e0e49.jpg)](http://dockone.io/uploads/article/20190714/0aac2c03a137b4f1c10ecce16c6e0e49.jpg)

- NoVolumeZoneConflict：检查给定的zone限制前提下，检查如果在此主机上部署Pod是否存在卷冲突。假定一些volumes可能有zone调度约束， VolumeZonePredicate根据volumes自身需求来评估pod是否满足条件。必要条件就是任何volumes的zone-labels必须与节点上的zone-labels完全匹配。节点上可以有多个zone-labels的约束（比如一个假设的复制卷可能会允许进行区域范围内的访问）。目前，这个只对PersistentVolumeClaims支持，而且只在PersistentVolume的范围内查找标签。处理在Pod的属性中定义的volumes（即不使用PersistentVolume）有可能会变得更加困难，因为要在调度的过程中确定volume的zone，这很有可能会需要调用云提供商。

- PodFitsResources：检查节点是否有足够资源（例如 CPU、内存与GPU等）满足一个Pod的运行需求。调度器首先会确认节点是否有足够的资源运行Pod，如果资源不能满足Pod需求，会返回失败原因（例如，CPU/内存 不足等）。这里需要注意的是：根据实际已经分配的资源量做调度，而不是使用已实际使用的资源量做调度。请参见我之前写的文章：《[Kubernetes之服务质量保证（QoS）](http://dockone.io/article/2592)》。

- PodFitsHostPorts：检查Pod容器所需的HostPort是否已被节点上其它容器或服务占用。如果所需的HostPort不满足需求，那么Pod不能调度到这个主机上。 注：1.0版本被称之为PodFitsPorts，1.0之后版本变更为PodFitsHostPorts，为了向前兼容PodFitsPorts名称仍然保留。

- HostName：检查节点是否满足PodSpec的NodeName字段中指定节点主机名，不满足节点的全部会被过滤掉。

- MatchNodeSelector：检查节点标签（label）是否匹配Pod的nodeSelector属性要求。关于nodeSelector请参见我之前写的文章：《[Kubernetes之Pod调度](http://dockone.io/article/2635) 》。

- MaxEBSVolumeCount：确保已挂载的EBS存储卷不超过设置的最大值（默认值为39。Amazon推荐最大卷数量为40，其中一个卷为root卷，具体可以参考[http://docs.aws.amazon.com/AWS ... imits](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/volume_limits.html#linux-specific-volume-limits)）。调度器会检查直接使用以及间接使用这种类型存储的PVC。计算不同卷的总和，如果卷数目会超过设置的最大值，那么新Pod不能调度到这个节点上。 最大卷的数量可通过环境变量KUBE_MAX_PD_VOLS设置。

- MaxGCEPDVolumeCount：确保已挂载的GCE存储卷不超过预设的最大值（GCE默认值最大存储卷值为16，具体可参见[https://cloud.google.com/compu ... types](https://cloud.google.com/compute/docs/disks/persistent-disks#limits_for_predefined_machine_types)）。与MaxEBSVolumeCount类似，最大卷的数量同样可通过环境变量KUBE_MAX_PD_VOLS设置。

- MaxAzureDiskVolumeCount : 确保已挂载的Azure存储卷不超过设置的最大值。默认值是16。规则同MaxEBSVolumeCount。

- CheckNodeMemoryPressure : 判断节点是否已经进入到内存压力状态，如果是则只允许调度内存为0标记的Pod。检查Pod能否调度到内存有压力的节点上。如有节点存在内存压力， Guaranteed类型的Pod（例如，requests与limit均指定且值相等） 不能调度到节点上。QoS相关请参见我之前写的文章：《[Kubernetes之服务质量保证（QoS）](http://dockone.io/article/2592)》。

- CheckNodeDiskPressure : 判断节点是否已经进入到磁盘压力状态，如果是，则不调度新的Pod。

- PodToleratesNodeTaints : 根据 taints 和 toleration 的关系判断Pod是否可以调度到节点上Pod是否满足节点容忍的一些条件。

- MatchInterPodAffinity : 节点亲和性筛选。

- GeneralPredicates：包含一些基本的筛选规则，主要考虑 Kubernetes 资源是否充足，比如 CPU 和 内存 是否足够，端口是否冲突、selector 是否匹配等：

  - PodFitsResources：检查主机上的资源是否满足Pod的需求。资源的计算是根据主机上运行Pod请求的资源作为参考的，而不是以实际运行的资源数量
  - PodFitsHost：如果Pod指定了spec.NodeName，看节点的名字是否何它匹配，只有匹配的节点才能运行Pod
  - PodFitsHostPorts：检查Pod申请的主机端口是否已经被其他Pod占用，如果是，则不能调度
  - PodSelectorMatches：检查主机的标签是否满足Pod的 selector。包括NodeAffinity和nodeSelector中定义的标签。


关于predicates更多详细的细节，请参考plugin/pkg/scheduler/algorithm/predicates/predicates.go：。
[Kubernetes之Pod调度](http://dockone.io/article/2635)
经过预选策略（Predicates）对节点过滤后，获取节点列表，再对符合需求的节点列表进行打分，最终选择Pod调度到一个分值最高的节点。Kubernetes用一组优先级函数处理每一个通过预选的节点（kubernetes/plugin/pkg/scheduler/algorithm/priorities中实现）。每一个优先级函数会返回一个0-10的分数，分数越高表示节点越优， 同时每一个函数也会对应一个表示权重的值。最终主机的得分用以下公式计算得出：

目前支持优选的优先级函数包括以下几种：

- LeastRequestedPriority：节点的优先级就由节点空闲资源与节点总容量的比值，即由（总容量-节点上Pod的容量总和-新Pod的容量）/总容量）来决定。CPU和内存具有相同权重，资源空闲比越高的节点得分越高。需要注意的是，这个优先级函数起到了按照资源消耗来跨节点分配Pod的作用。详细的计算规则如下：

  cpu((capacity – sum(requested)) * 10 / capacity) + memory((capacity – sum(requested)) * 10 / capacity) / 2

  [![6.jpg](http://dockone.io/uploads/article/20190714/8099a97b5113a716aaab0ba1077da8ee.jpg)](http://dockone.io/uploads/article/20190714/8099a97b5113a716aaab0ba1077da8ee.jpg)

  注：10 表示非常合适，0 表示完全不合适。

  LeastRequestedPriority举例说明：例如CPU的可用资源为100，运行容器申请的资源为15，则cpu分值为8.5分，内存可用资源为100，运行容器申请资源为20，则内存分支为8分。则此评价规则在此节点的分数为(8.5 +8) / 2 = 8.25分。

- BalancedResourceAllocation：CPU和内存使用率越接近的节点权重越高，该策略不能单独使用，必须和LeastRequestedPriority组合使用，尽量选择在部署Pod后各项资源更均衡的机器。如果请求的资源（CPU或者内存）大于节点的capacity，那么该节点永远不会被调度到。

- BalancedResourceAllocation举例说明：该调度策略是出于平衡度的考虑，避免出现CPU，内存消耗不均匀的事情。例如某节点的CPU剩余资源还比较充裕，假如为100，申请10，则cpuFraction为0.1，而内存剩余资源不多，假如为20，申请10，则memoryFraction为0.5，这样由于CPU和内存使用不均衡，此节点的得分为10-abs ( 0.1 - 0.5 ) * 10 = 6 分。假如CPU和内存资源比较均衡，例如两者都为0.5，那么代入公式，则得分为10分。

- InterPodAffinityPriority：通过迭代 weightedPodAffinityTerm 的元素计算和，并且如果对该节点满足相应的PodAffinityTerm，则将 “weight” 加到和中，具有最高和的节点是最优选的。 `

- SelectorSpreadPriority：为了更好的容灾，对同属于一个service、replication controller或者replica的多个Pod副本，尽量调度到多个不同的节点上。如果指定了区域，调度器则会尽量把Pod分散在不同区域的不同节点上。当一个Pod的被调度时，会先查找Pod对于的service或者replication controller，然后查找service或replication controller中已存在的Pod，运行Pod越少的节点的得分越高。

  SelectorSpreadPriority举例说明：这里主要针对多实例的情况下使用。例如，某一个服务，可能存在5个实例，例如当前节点已经分配了2个实例了，则本节点的得分为10*（（5-2）/ 5）=6分，而没有分配实例的节点，则得分为10 * （（5-0） / 5）=10分。没有分配实例的节点得分越高。

  注：1.0版本被称之为ServiceSpreadingPriority，1.0之后版本变更为SelectorSpreadPriority，为了向前兼容ServiceSpreadingPriority名称仍然保留。

- NodeAffinityPriority：Kubernetes调度中的亲和性机制。Node Selectors（调度时将pod限定在指定节点上），支持多种操作符（In, NotIn, Exists, DoesNotExist, Gt, Lt），而不限于对节点labels的精确匹配。另外，Kubernetes支持两种类型的选择器，一种是“hard（requiredDuringSchedulingIgnoredDuringExecution）”选择器，它保证所选的主机必须满足所有Pod对主机的规则要求。这种选择器更像是之前的nodeselector，在nodeselector的基础上增加了更合适的表现语法。另一种是“soft（preferresDuringSchedulingIgnoredDuringExecution）”选择器，它作为对调度器的提示，调度器会尽量但不保证满足NodeSelector的所有要求。

- NodePreferAvoidPodsPriority（权重1W）：如果 节点的 Anotation 没有设置 key-value:scheduler. alpha.kubernetes.io/ preferAvoidPods = "..."，则节点对该 policy 的得分就是10分，加上权重10000，那么该node对该policy的得分至少10W分。如果Node的Anotation设置了，scheduler.alpha.kubernetes.io/preferAvoidPods = "..." ，如果该 pod 对应的 Controller 是 ReplicationController 或 ReplicaSet，则该 node 对该 policy 的得分就是0分。

- TaintTolerationPriority : 使用 Pod 中 tolerationList 与 节点 Taint 进行匹配，配对成功的项越多，则得分越低。


另外在优选的调度规则中，有几个未被默认使用的规则：

- ImageLocalityPriority：根据Node上是否存在一个pod的容器运行所需镜像大小对优先级打分，分值为0-10。遍历全部Node，如果某个Node上pod容器所需的镜像一个都不存在，分值为0；如果Node上存在Pod容器部分所需镜像，则根据这些镜像的大小来决定分值，镜像越大，分值就越高；如果Node上存在pod所需全部镜像，分值为10。

  [![7.jpg](http://dockone.io/uploads/article/20190714/e8c8faaeb955cb6b2f4f6e2a8b6cdbca.jpg)](http://dockone.io/uploads/article/20190714/e8c8faaeb955cb6b2f4f6e2a8b6cdbca.jpg)

  注：10 表示非常合适，0 表示完全不合适。

- EqualPriority : EqualPriority 是一个优先级函数，它给予所有节点相等权重。

- MostRequestedPriority : 在 ClusterAutoscalerProvider 中，替换 LeastRequestedPriority，给使用多资源的节点，更高的优先级。计算公式为：(cpu(10 sum(requested) / capacity) + memory(10 sum(requested) / capacity)) / 2


要想获得所有节点最终的权重分值，就要先计算每个优先级函数对应该节点的分值，然后计算总和。因此不管过程如何，如果有 N 个节点，M 个优先级函数，一定会计算 M*N 个中间值，构成一个二维表格：

[![8.jpg](http://dockone.io/uploads/article/20190714/4953cd33ea0f91beac700ffe119fa3fb.jpg)](http://dockone.io/uploads/article/20190714/4953cd33ea0f91beac700ffe119fa3fb.jpg)


最后，会把表格中按照节点把优先级函数的权重列表相加，得到最终节点的分值。上面代码就是这个过程，中间过程可以并发计算（下文图中的workQueue），以加快速度。

### 自定义调度

使用kube-schduler的默认调度就能满足大部分需求。在默认情况下，Kubernetes调度器可以满足绝大多数需求，例如调度Pod到资源充足的节点上运行，或调度Pod分散到不同节点使集群节点资源均衡等。前面已经提到，kubernetes的调度器以插件化的形式实现的， 方便用户对调度的定制与二次开发。下面介绍几种方式：

#### 方式一：定制预选（Predicates） 和优选（Priority）策略

kube-scheduler在启动的时候可以通过 --policy-config-file参数可以指定调度策略文件，用户可以根据需要组装Predicates和Priority函数。选择不同的过滤函数和优先级函数、控制优先级函数的权重、调整过滤函数的顺序都会影响调度过程。
考官方给出的Policy文件实例：

```
"kind" : "Policy",
"apiVersion" : "v1",
"predicates" : [
    {"name" : "PodFitsHostPorts"},
    {"name" : "PodFitsResources"},
    {"name" : "NoDiskConflict"},
    {"name" : "NoVolumeZoneConflict"},
    {"name" : "MatchNodeSelector"},
    {"name" : "HostName"}
    ],
"priorities" : [
    {"name" : "LeastRequestedPriority", "weight" : 1},
    {"name" : "BalancedResourceAllocation", "weight" : 1},
    {"name" : "ServiceSpreadingPriority", "weight" : 1},
    {"name" : "EqualPriority", "weight" : 1}
    ],
"hardPodAffinitySymmetricWeight" : 10 
```



#### 方式二：自定义Priority和Predicate

上面的方式一是对已有的调度模块进行组合，Kubernetes还允许用户编写自己的Priority 和 Predicate函数。
过滤函数的接口：

```
// FitPredicate is a function that indicates if a pod fits into an existing node.
// The failure information is given by the error.
type FitPredicate func(pod *v1.Pod, meta PredicateMetadata, nodeInfo *schedulercache.NodeInfo) (bool, []PredicateFailureReason, error)
```





除了上面2种方式外，Kubernetes也允许用户编写自己的调度器组件，并在创建资源的时候引用它。多个调度器可以同时运行和工作，只要名字不冲突。

调度器最核心的逻辑并不复杂。Scheduler首先监听apiserver ，获取没有被调度的Pod和全部节点列表，而后根据一定的算法和策略从节点中选择一个作为调度结果，最后向apiserver中写入binding 。比如下面就是用bash编写的简单调度器：

```
#!/bin/bash
SERVER='localhost:8001'
while true;
do
for PODNAME in $(kubectl --server $SERVER get pods -o json | jq '.items[] | select(.spec.schedulerName == "my-scheduler") | select(.spec.nodeName == null) | .metadata.name' | tr -d '"')
;
do
    NODES=($(kubectl --server $SERVER get nodes -o json | jq '.items[].metadata.name' | tr -d '"'))
    NUMNODES=${#NODES[@]}
    CHOSEN=${NODES[$[ $RANDOM % $NUMNODES ]]}
    curl --header "Content-Type:application/json" --request POST --data '{"apiVersion":"v1", "kind": "Binding", "metadata": {"name": "'$PODNAME'"}, "target": {"apiVersion": "v1", "kind"
: "Node", "name": "'$CHOSEN'"}}' http://$SERVER/api/v1/namespaces/default/pods/$PODNAME/binding/
    echo "Assigned $PODNAME to $CHOSEN"
done
sleep 1
done 
```


它通过kubectl命令从apiserver获取未调度的Pod（spec.schedulerName 是my-scheduler，并且spec.nodeName 为空），同样地，用kubectl从apiserver获取nodes的信息，然后随机选择一个node作为调度结果，并写入到apiserver中。





#### Pod优先级（Priority）

Pod优先级（Priority）和抢占（Preemption）是Kubernetes 1.8版本引入的功能，在1.8版本默认是禁用的，当前处于Alpha阶段，不建议在生产环境使用。
与前面所讲的调度优选策略中的优先级（Priorities）不同，前文所讲的优先级指的是节点优先级，而pod priority指的是Pod的优先级，高优先级的Pod会优先被调度，或者在资源不足低情况牺牲低优先级的Pod，以便于重要的Pod能够得到资源部署。




当节点没有足够的资源供调度器调度Pod、导致Pod处于pending时，抢占（preemption）逻辑会被触发。Preemption会尝试从一个节点删除低优先级的Pod，从而释放资源使高优先级的Pod得到节点资源进行部署。
[https://kubernetes.io/docs/con ... tion/](https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/)
回过头来，再重新看一下Pod的调度过程，也许会清晰很多。如下图示例：

[![10.jpg](http://dockone.io/uploads/article/20190714/0e164572b606bf04b47eecafaf704f68.jpg)](http://dockone.io/uploads/article/20190714/0e164572b606bf04b47eecafaf704f68.jpg)


注：使用 workQueue 来并行运行检查，并发数最大是 16。对应源码示例：orkqueue.Parallelize(16, len(nodes), checkNode)。

### 总结

本次分享主要介绍了Pod的预选与优选调度策略、Kubernetes调度的定制与开发，以及Kubernetes1.8的Pod优先级和抢占等新特性。
没有什么事情是完美的，调度器也一样，用户可结合实际业务服务特性和需求，利用或定制Kubernetes调度策略，更好满足业务服务的需求。

### Q&A

**Q：普通用户有自定义Pod优先级的权限吗？**
**Q：Kubernetes scheduler extender能介绍一下么？**

> A：extender可理解为Kubernetes调度策略和算法的扩展，属于自定义调度器的一种方式，与Kubernetes默认调度器的过程类似，主要是针对一些不算受集群本身控制的资源（比如网络），需要通过外部调用来进行调度的情况。

**Q：用户使用了NodeSelector指定了Pod调度的node节点后，如果node不可用，那么scheduler会采用别的策略吗？**
以上内容根据2017年11月14日晚微信群分享内容整理。**分享人张夏，FreeWheel 主任工程师。研究生毕业于中国科学技术大学，近10年IT领域工作经验，曾先后供职于IBM与新浪微博等公司。目前主要负责公司基于Kubernetes容器云平台建设，致力于Kubernetes容器云产品化与平台化**





# 参考

1. [DockOne微信分享（一四九）：Kubernetes调度详解](http://dockone.io/article/2885)