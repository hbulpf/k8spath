#!/bin/bash

rm_docker(){
    if [ -n "$1" ] ; then
        keyword=$1
    else
        keyword=8895
    fi

    cid=`docker ps | grep infer | grep ${keyword} | awk '{print $1}'`

    if [ -n "${cid}" ]; then
        c_str=`docker ps --format "{{.ID}}, name: {{.Names}}, image:{{.Image}}" | grep ${cid}`
        echo "delete: ${c_str}"
        docker stop ${cid} && docker rm ${cid}
    fi
}

godocker(){
    if [ $# -eq 1 ]; then
        c=$1
        docker exec -it $c bash
    else
        echo 'need container name as param'
    fi
}

occupid_npus_docker(){
    cids=`docker ps -q`
    busy_npus=()
    for cid in ${cids}
    do
        c_str=`docker ps --format "{{.ID}}, name: {{.Names}}, image:{{.Image}}" | grep ${cid}`
        c_npu_str=`docker inspect ${cid} | grep /dev/davinci | cut -d '"' -f 4 | uniq | sort | grep -v manager`
        OLD_IFS="$IFS"
        IFS=$'\n'
        c_npus=(${c_npu_str})
        IFS="$OLD_IFS"
        if [ -n "${c_npu_str}" ]; then
            echo -e "----${c_str}-----\n ${c_npu_str}"
            for c_npu in ${c_npus[*]}
            do
                busy_npus[${#busy_npus[*]}]=${c_npu}
            done
        fi
    done
    res=`echo ${busy_npus[@]} | sed 's/ /\n/g' | sort | uniq`
    echo -e "busy npus:\n${res}"
}

dstats(){
    if [ -n "$1" ]; then
        keyword=$1
        c_name=`docker ps --format "{{.ID}} {{.Image}} {{.Names}}" | grep ${keyword} |grep -v '/pause' | awk '{print $3}'`
        docker stats ${c_name}
    else
        echo 'need container name as param'
    fi
}

drestart_num(){
    if [ -n "$1" ]; then
        c_name=$1
        docker inspect -f "restart:{{.RestartCount}} , lastStart:{{.State.StartedAt}}" ${c_name}
    else
        echo 'need container name as param'
    fi
}
