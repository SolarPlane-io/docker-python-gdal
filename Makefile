GDAL_VERSION ?= 3.8.5
PYTHON_VERSION ?= 3.11.7
ACCOUNT = 654654581134
REGION = us-west-2
DOCKER_REPO ?= $(ACCOUNT).dkr.ecr.$(REGION).amazonaws.com/python-gdal
IMAGE ?= $(DOCKER_REPO):py$(PYTHON_VERSION)-gdal$(GDAL_VERSION)

image:
	docker build \
		--build-arg GDAL_VERSION=$(GDAL_VERSION) \
		--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
		-t $(IMAGE) .

test:
	docker run --rm $(IMAGE)

lint:
	docker run \
		--rm \
		-v `pwd`/.dockerfilelintrc:/.dockerfilelintrc \
		-v `pwd`/Dockerfile:/Dockerfile \
		replicated/dockerfilelint /Dockerfile

push-image:
	$(shell aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT.dkr.ecr.$REGION.amazonaws.com)
	docker push $(IMAGE)

.PHONY: image test lint push-image
