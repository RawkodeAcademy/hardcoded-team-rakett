[private]
default:
  just --list -u

[working-directory: "Hardcoded/Normalizer"]
build-normalizer TAG="latest":
  docker build -t normalizer:{{TAG}} .
  docker tag normalizer:latest ttl.sh/myapp:1h
  docker push ttl.sh/normalizer:1h

build TAG="latest":
  just build-normalizer {{TAG}}
