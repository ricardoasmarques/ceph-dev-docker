WORKSPACE="$(dirname "$(pwd)")"

NAME="${NAME:-ceph-1}"
CEPH="${CEPH:-$WORKSPACE/ceph}"
CCACHE="${CCACHE:-$WORKSPACE/ceph-ccache}"
VERSION="${VERSION:-master}"

# Removes old container with same name
docker stop $NAME
docker rm $NAME

DOCKER_BUILD_OPTS="--pull"

# Build updated version of the image
case "$VERSION" in
"mimic")
  TAG="ceph-dev-docker-mimic"
  docker build $DOCKER_BUILD_OPTS -t $TAG -f mimic.Dockerfile .
  ;;
"nautilus")
  TAG="ceph-dev-docker-nautilus"
  docker build $DOCKER_BUILD_OPTS -t $TAG -f nautilus.Dockerfile .
  ;;
"octopus")
  TAG="ceph-dev-docker-octopus"
  docker build $DOCKER_BUILD_OPTS -t $TAG -f octopus.Dockerfile .
  ;;
*)
  TAG="ceph-dev-docker"
  docker build $DOCKER_BUILD_OPTS -t $TAG .
  ;;
esac

# Creates a container with all recommended configs
docker run -itd \
  -v $CEPH:/ceph \
  -v $CCACHE:/root/.ccache \
  -v $(pwd)/shared:/shared \
  -v /run/udev:/run/udev:ro \
  -v ~/.ssh:/root/.ssh:ro \
  --privileged \
  --net=host \
  --name=$NAME \
  --hostname=$NAME \
  --add-host=$NAME:127.0.0.1 \
  $TAG

docker exec -it $NAME zsh
