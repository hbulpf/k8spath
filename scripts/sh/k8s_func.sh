#!/bin/bash
  
kpod(){
    if [ -n "$1" ] ; then
        keyword=$1
    else
        echo 'no keyword.output pod info of mx_aoi_service'
        kubectl get pod -o wide | grep infer
    fi
    kubectl get pod -o wide | grep ${keyword}
}

kdesc(){
    if [ -n "$1" ] ; then
        keyword=$1
    else
        echo 'no keyword.output pod info of mx_aoi_service'
    fi
    kubectl describe pod ${keyword}
}

kinto(){
    if [ -n "$1" ] ; then
        pod=$1
    else
        echo 'please input pod'
    fi
    kubectl exec -it ${pod} -- bash
}

klog(){
    if [ -n "$1" ] ; then
        pod=$1
    else
        echo 'please input pod'
    fi
    kubectl logs -f ${pod}
}

kloginfer_server(){
    if [ -n "$1" ] ; then
        pod=$1
    else
        echo 'please input pod'
    fi
    kubectl exec ${pod} -- tail -f /inference/sdk_rw/logs/ai_server.log
}