#!/bin/bash

ksearch(){
    if [ -n "$1" ] ; then
        keyword=$1
    else
        echo 'please input keyword'
    fi
    kubectl get pod | grep ${keyword}
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

kserinferlog(){
    if [ -n "$1" ] ; then
        pod=$1
    else
        echo 'please input pod'
    fi
    kubectl exec ${pod} -- tail -f /inference/sdk_rw/logs/ai_server.log
}