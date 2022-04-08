# Build environment
# -----------------
FROM golang:1.17-alpine as build-env
WORKDIR /app
RUN apk update && apk add --no-cache gcc musl-dev git
COPY . .
RUN go build -o ./bin/service ./app

# Deployment environment
# ----------------------
FROM alpine
WORKDIR /opt
RUN apk update && apk add --no-cache bash
COPY --from=build-env /app/bin/service .
COPY app/migrations /opt/migrations
COPY app/templates /opt/templates
CMD ["/opt/service"]