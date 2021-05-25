# PostGIS DB
docker run \
  --datach \
  --publish 5432:5432 \
  --name postgis \
  --restart unless-stopped \
  --volume $(pwd)/db/data:/var/lib/postgresql/data \
  beginor/postgis:9.3

# GeoServer Web
docker run \
  --detach \
  --publish 8080:8080 \
  --name geoserver \
  --restart unless-stopped \
  --volume $(pwd)/geoserver/data_dir:/geoserver/data_dir \
  --volume $(pwd)/geoserver/logs:/geoserver/logs \
  --hostname geoserver \
  --link postgis:postgis \
  beginor/geoserver:2.11.0