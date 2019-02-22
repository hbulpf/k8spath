#!/bin/bash

images=(
    nginx-ingress-controller:0.9.0-beta.10 
    defaultbackend:1.0)
for imageName in ${images[@]} ; do
    docker pull docker.io/chenliujin/$imageName
    docker tag docker.io/chenliujin/$imageName gcr.io/google_containers/$imageName 
    docker rmi docker.io/chenliujin/$imageName
done  