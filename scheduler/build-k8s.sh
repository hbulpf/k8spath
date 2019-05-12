
docker pull gcrcontainer/kube-cross:v1.10.8-1
docker tag gcrcontainer/kube-cross:v1.10.8-1 k8s.gcr.io/kube-cross:v1.10.8-1

docker tag docker.io/googlecontainer/kube-cross:v1.10.8-1 k8s.gcr.io/kube-cross:v1.10.8-1

docker pull docker.io/googlecontainer/debian-iptables-amd64:v11.0
docker tag docker.io/googlecontainer/debian-iptables-amd64:v11.0 gcr.io/googlecontainer/debian-iptables-amd64:v11.0