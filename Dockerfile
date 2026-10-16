FROM golang:1.27-alpine AS build

WORKDIR /src
COPY go.mod ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /out/dummy ./cmd/dummy

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=build /out/dummy /usr/local/bin/dummy
USER 65532:65532
ENTRYPOINT ["/usr/local/bin/dummy"]
