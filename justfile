[private]
default:
  just --list -u

[working-directory: "Hardcoded/Normalizer"]
build-normalizer TAG="latest":
  docker build -t ttl.sh/normalizer:{{TAG}} .
  docker tag normalizer:latest ttl.sh/myapp:{{TAG}}
  docker push ttl.sh/normalizer:{{TAG}}

[working-directory: "Hardcoded/Normalizer"]
run-normalizer TAG="latest":
  docker build -t normalizer .
  docker run normalizer -p 5037:5037


build TAG="1m":
  just build-normalizer {{TAG}}

test TAG="1m":
  just run-normalizer
