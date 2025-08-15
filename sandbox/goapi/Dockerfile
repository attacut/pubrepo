FROM golang:1.24.6 AS build-env

WORKDIR /app

COPY go.mod ./

RUN go mod download

COPY . .

RUN go build -o goapi ./cmd/main.go

FROM gcr.io/distroless/base-debian12

WORKDIR /app

COPY --from=build-env /app/goapi .

ENTRYPOINT ["./goapi"]
