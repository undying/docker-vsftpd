
NAME=$(shell basename `pwd`)
RUN=docker run --name $(NAME) -d \
		-P \
		-p 10100:10100 \
		-p 10101:10101 \
		$(NAME)

.PHONY: build run stop clean

build: clean
	docker build -t $(NAME) .

run:
	$(eval ID := $(shell $(RUN)))
	docker logs -ft $(ID)

stop:
	docker stop $(NAME) || true

clean: stop
	docker rm $(NAME) || true

all: clean build run

