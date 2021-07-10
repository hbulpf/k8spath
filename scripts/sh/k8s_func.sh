#!/bin/bash

kpod(){
    if [ -n "$1" ] ; then
        keyword=$1
    else
        echo 'no keyword,default: infer'
        kubectl get pod -o wide | grep infer
    fi
    kubectl get pod -o wide | grep ${keyword}
}

kdesc(){
    if [ -n "$1" ] ; then
        keyword=$1
    else
        echo 'please input keyword'
        return 0
    fi
    getpod_by_keyword pod_by_word ${keyword}
    kubectl describe pod ${pod_by_word}
}

kinto(){
    if [ -n "$1" ] ; then
        keyword=$1
    else
        echo 'please input keyword'
        return 0
    fi
    getpod_by_keyword pod_by_word ${keyword}
    kubectl exec -it ${pod_by_word} -- bash
}

klog(){
    if [ -n "$1" ] ; then
        keyword=$1
    else
        echo 'please input keyword'
        return 0
    fi
    getpod_by_keyword pod_by_word ${keyword}
    kubectl logs -f ${pod_by_word}
}

kloginfer_server(){
    getpod_by_keyword pod_by_word 'infer'
    kubectl exec ${pod_by_word} -- tail -f /inference/sdk_rw/logs/ai_server.log
}

getpod_by_keyword(){
    if [ -z "$2" ] ; then
        echo 'please input keyword of pod'
        return 'no_pod'
    fi
    keyword=$2
    candidates=`kubectl get pod -o custom-columns=NAME:.metadata.name | grep ${keyword}`
    line_no=0
    for candidate in ${candidates}
    do
        let line_no++
        echo ${line_no} : ${candidate}
    done
    let line_no--

    if [ $[line_no] -gt 1 ]; then
        echo 'please choose number of pod:'
        read num
    else
        num=0
    fi
    pod_name=`echo ${candidates} | awk -v t="${num}" '{print $t}'`
    echo pod_name: ${pod_name}
    eval "$1=${pod_name}"
}

kstats(){
    if [ -n "$1" ]; then
        keyword=$1
    else
        echo 'please input keyword'
        return 0
    fi
    getpod_by_keyword pod_by_word ${keyword}
    c_name=`docker ps --format "{{.ID}} {{.Image}} {{.Names}}" | grep ${pod_by_word} |grep -v '/pause' | awk '{print $3}'`
    echo "container(${c_name}) found"
    c_name=`echo ${c_name} | sed 's/ //g'`
    if [ -z "${c_name}" ]; then
        echo "Err: not found container by (${pod_by_word}). pod is crashed or pod is on other node!"
        kpod ${pod_by_word}
    else
        docker stats ${c_name}
    fi
}
