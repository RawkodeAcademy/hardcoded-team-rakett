[private]
default:
  just --list -u

[working-directory: "Hardcoded/Normalizer"]
build-normalizer TAG="latest":
  docker build -t ttl.sh/normalizer:{{TAG}} .
  #docker tag ttl.sh/normalizer:{{TAG}} ttl.sh/myapp:{{TAG}}
  docker push ttl.sh/normalizer:{{TAG}}

[working-directory: "Hardcoded/Normalizer"]
run-normalizer TAG="latest":
  docker build -t normalizer .
  docker run -p 5037:8080 normalizer

[working-directory: "Hardcoded/Tokenizer"]
build-tokenizer TAG="latest":
  docker build -t ttl.sh/tokenizer:{{TAG}} .
  # docker tag ttl.sh/tokenizer:{{TAG}} ttl.sh/tokenizer:{{TAG}}
  docker push ttl.sh/tokenizer:{{TAG}}

[working-directory: "Hardcoded/Tokenizer"]
run-tokenizer TAG="latest":
  docker build -t tokenizer .
  docker run -p 3000:3000 tokenizer

build TAG="1m":
  just build-normalizer {{TAG}}
  just build-tokenizer {{TAG}}

[working-directory: "manifests"]
render TAG="latest":
  cue export --out yaml -t name=normalizer -t tag={{TAG}} -t image=ttl.sh/normalizer | yq .deployment > _rendered/normalizer-dep.yaml
  cue export --out yaml -t name=normalizer -t tag={{TAG}} -t image=ttl.sh/normalizer | yq .deployment > _rendered/normalizer-service.yaml
  cue export --out yaml -t name=tokenizer -t tag={{TAG}} -t image=ttl.sh/tokenizer | yq .deployment > _rendered/tokenizer-dep.yaml
  cue export --out yaml -t name=tokenizer -t tag={{TAG}} -t image=ttl.sh/tokenizer | yq .deployment > _rendered/tokenizer-service.yaml

apply:
  kubectl apply -f manifests/_rendered/

test TAG="1m":
  just run-normalizer
  just run-tokenizer

all:
  just build 1m
  just render 1m
  just apply
