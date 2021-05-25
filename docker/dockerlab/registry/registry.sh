docker run \
  --detach \
  --name registry \
  --hostname registry \
  --volume $(pwd)/app/registry:/var/lib/registry \
  --publish 5003:5000 \
  --restart unless-stopped \
  registry:latest