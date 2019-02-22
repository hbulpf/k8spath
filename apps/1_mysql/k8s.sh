#! /bin/bash
systemctl disable firewalld
systemctl stop firewalld
yum install -y etcd kubernetes

vim /etc/sysconfig/docker
#/etc/sysconfig/docker中OPTIONS的内容改为
#OPTIONS='--selinux-enabled=false --insecure-registry gcr.io'
vim /etc/kubernetes/apiserver
#vim /etc/kubernetes/apiserver
#去掉--admission_control参数中的ServiceAccount

systemctl enable etcd
systemctl enable docker
systemctl enable kube-apiserver
systemctl enable kube-controller-manager
systemctl enable kube-scheduler
systemctl enable kubelet
systemctl enable kube-proxy

systemctl start etcd
systemctl start docker
systemctl start kube-apiserver
systemctl start kube-controller-manager
systemctl start kube-scheduler
systemctl start kubelet
systemctl start kube-proxy

#出现问题时运行
# yum install *rhsm* 
# wget http://mirror.centos.org/centos/7/os/x86_64/Packages/python-rhsm-certificates-1.19.10-1.el7_4.x86_64.rpm
# rpm2cpio python-rhsm-certificates-1.19.10-1.el7_4.x86_64.rpm | cpio -iv --to-stdout ./etc/rhsm/ca/redhat-uep.pem | tee /etc/rhsm/ca/redhat-uep.pem
# docker pull registry.access.redhat.com/rhel7/pod-infrastructure:latest

kubectl create -f ./mysql-rc.yaml
kubectl get rc
kubectl get pod

kubectl create -f ./mysql-svc.yaml
kubectl get svc