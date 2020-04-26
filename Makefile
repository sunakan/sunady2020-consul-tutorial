export DOCKER_CONSUL_TAG=1.7
export DOCKER_NETWORK_NAME=my-consul-network

define local-consul-common
	docker run \
		--detach \
		--rm \
		--interactive \
		--tty \
		--network ${DOCKER_NETWORK_NAME} \
		--name $1 \
		--hostname $1
endef

define local-consul-options
		agent \
		-server \
		-bootstrap-expect 5 \
		-client 0.0.0.0
endef

network:
	docker network ls | grep ${DOCKER_NETWORK_NAME} \
		|| docker network create ${DOCKER_NETWORK_NAME}

n1: network
	$(call local-consul-common, n1) \
		--publish 8400:8400 \
		--publish 8500:8500 \
		--publish 8600:8600 \
		--publish 8600:8600/udp \
		consul:${DOCKER_CONSUL_TAG} \
		$(call local-consul-options) \
		-ui

n2: network
	$(call local-consul-common, n2) \
		consul:${DOCKER_CONSUL_TAG} \
		$(call local-consul-options) \
		-retry-join n1

n3: network
	$(call local-consul-common, n3) \
		consul:${DOCKER_CONSUL_TAG} \
		$(call local-consul-options) \
		-retry-join n1

n4: network
	$(call local-consul-common, n4) \
		consul:${DOCKER_CONSUL_TAG} \
		$(call local-consul-options) \
		-retry-join n1

n5: network
	$(call local-consul-common, n5) \
		consul:${DOCKER_CONSUL_TAG} \
		$(call local-consul-options) \
		-retry-join n1

up:
	make n1
	make n2
	make n3
	make n4
	make n5

clean:
	docker container ls --quiet --filter "name=n*" | xargs -I {} docker stop {}
	docker network ls --quiet --filter "name=${DOCKER_NETWORK_NAME}" | xargs -I {} docker network rm {}
