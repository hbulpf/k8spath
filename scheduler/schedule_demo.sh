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

# 通过kubectl命令从apiserver获取未调度的Pod（spec.schedulerName 是my-scheduler，并且spec.nodeName 为空），
# 同样地，用kubectl从apiserver获取nodes的信息，然后随机选择一个node作为调度结果，并写入到apiserver中。
