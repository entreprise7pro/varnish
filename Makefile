-include env.mk

#VARNISH_VER ?= 4.1.10
# Je pensait me servir de 4.1.10 mais j'ai testé 6.0.3 et ça marche bien sans perdre compatibilité.
VARNISH_VER ?= 6.0.3
VARNISH_VER_MINOR = $(shell v='$(VARNISH_VER)'; echo "$${v%.*}")

ALPINE_VER ?= 3.9

ifeq ($(BASE_IMAGE_STABILITY_TAG),)
    BASE_IMAGE_TAG := $(ALPINE_VER)
else
    BASE_IMAGE_TAG := $(ALPINE_VER)-$(BASE_IMAGE_STABILITY_TAG)
endif

TAG ?= $(VARNISH_VER_MINOR)

REPO = entreprise7pro/varnish
NAME = varnish-$(VARNISH_VER_MINOR)

ifneq ($(STABILITY_TAG),)
    ifneq ($(TAG),latest)
        override TAG := $(TAG)-$(STABILITY_TAG)
    endif
endif

.PHONY: build test test-clean push shell run start stop logs clean release

default: build

build:
	docker build -t $(REPO):$(TAG) \
	    --build-arg BASE_IMAGE_TAG=$(BASE_IMAGE_TAG) \
	    --build-arg VARNISH_VER=$(VARNISH_VER) ./

test:
	cd ./tests/basic && IMAGE=$(REPO):$(TAG) ./run.sh
	cd ./tests/drupal && IMAGE=$(REPO):$(TAG) ./run.sh
	cd ./tests/wordpress && IMAGE=$(REPO):$(TAG) ./run.sh

push:
	docker push $(REPO):$(TAG)

shell:
	docker run --rm --name $(NAME) -i -t $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) /bin/bash

run:
	docker run --rm --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) $(CMD)

start:
	docker run -d --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG)

stop:
	docker stop $(NAME)

logs:
	docker logs $(NAME)

clean:
	-docker rm -f $(NAME)

release: build push
