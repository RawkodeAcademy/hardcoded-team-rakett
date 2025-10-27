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
  docker run -p 5037:5037 normalizer

[working-directory: "Hardcoded/Tokenizer"]
build-tokenizer TAG="latest":
  docker build -t ttl.sh/tokenizer:{{TAG}} .
  docker tag tokenizer:latest ttl.sh/tokenizer:{{TAG}}
  docker push ttl.sh/tokenizer:{{TAG}}

[working-directory: "Hardcoded/Tokenizer"]
run-tokenizer TAG="latest":
  docker build -t tokenizer .
  docker run -p 3000:3000 tokenizer

build TAG="1m":
  just build-normalizer {{TAG}}
  just build-tokenizer {{TAG}}

test TAG="1m":
  just run-normalizer
  just run-tokenizer
