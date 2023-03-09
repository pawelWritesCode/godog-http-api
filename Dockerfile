FROM golang:1.20.1-buster
WORKDIR /godog-http-api

RUN go install github.com/cucumber/godog/cmd/godog@v0.12.6

ENTRYPOINT ["godog"]
CMD ["run", "--concurrency=2", "--format=progress"]