WORKSPACE="$(dirname "$(pwd)")"

NAME="${NAME:-ceph-1}"
CEPH="${CEPH:-$WORKSPACE/ceph}"
CCACHE="${CCACHE:-$WORKSPACE/ceph-ccache}"

# Removes old container with same name
docker stop $NAME
docker rm $NAME

# Build updated version of the image
docker build -t ceph-dev-docker .

# Creates a container with all recommended configs
docker run -itd \
  -v $CEPH:/ceph \
  -v $CCACHE:/root/.ccache \
  -v $(pwd)/shared:/shared \
  --net=host \
  --name=$NAME \
  --hostname=$NAME \
  --add-host=$NAME:127.0.0.1 \
  ceph-dev-docker
