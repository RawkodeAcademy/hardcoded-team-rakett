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

[working-directory: "Hardcoded/Aggregator"]
build-aggregator TAG="latest":
  docker build -t ttl.sh/aggregator:{{TAG}} .
  docker push ttl.sh/aggregator:{{TAG}}

[working-directory: "Hardcoded/Aggregator"]
run-aggregator TAG="latest":
  docker build -t aggregator .
  docker run -p 8080:8080 aggregator

build TAG="1m":
  just build-normalizer {{TAG}}  curl -X POST http://localhost:4000/analyze \
    -H "Content-Type: application/json" \
    -d '{"text": "Hello World!"}'
  just build-tokenizer {{TAG}}
  just build-aggregator {{TAG}}

[working-directory: "manifests"]
render TAG="latest":
  cue export --out yaml -t name=normalizer -t tag={{TAG}} -t image=ttl.sh/normalizer | yq .deployment > _rendered/normalizer-dep.yaml
  cue export --out yaml -t name=normalizer -t tag={{TAG}} -t image=ttl.sh/normalizer | yq .service > _rendered/normalizer-service.yaml
  cue export --out yaml -t name=tokenizer -t tag={{TAG}} -t image=ttl.sh/tokenizer | yq .deployment > _rendered/tokenizer-dep.yaml
  cue export --out yaml -t name=tokenizer -t tag={{TAG}} -t image=ttl.sh/tokenizer | yq .service > _rendered/tokenizer-service.yaml

apply:
  kubectl apply -f manifests/_rendered/

test TAG="1m":
  just run-normalizer
  just run-tokenizer

all:
  just build 1m
  just render 1m
  just apply
