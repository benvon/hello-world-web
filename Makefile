# Makefile for hello-world-web local development and testing

IMAGE_NAME=hello-world-web
CONTAINER_NAME=hello-world-web-test
PORT_WEB=8080
PORT_API=8081

.PHONY: build run stop health logs clean

build:
	docker build -t $(IMAGE_NAME) .

run:
	docker run -d --rm \
	  --name $(CONTAINER_NAME) \
	  -p $(PORT_WEB):8080 \
	  -p $(PORT_API):8081 \
	  $(IMAGE_NAME)

stop:
	docker stop $(CONTAINER_NAME) || true

health:
	@echo "Checking backend API health..."
	curl -f http://localhost:$(PORT_API)/api/health || (echo "Health check failed" && exit 1)

logs:
	docker logs -f $(CONTAINER_NAME)

clean:
	docker rmi $(IMAGE_NAME) || true 