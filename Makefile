SHELL=/bin/bash -o pipefail

ifeq ($(TRAVIS),true)
  $(eval compose_files := base travis)
else
  $(eval compose_files := base local)
endif

define docker-compose
	$(eval files := $(addprefix -f docker-compose.,$(addsuffix .yml,$(compose_files))))
	docker-compose $(files) $1
endef

.PHONY: build
build:
	$(call docker-compose,build)

.PHONY: run
run:
	$(call docker-compose,up)

.PHONY: run-detached
run-detached:
	$(call docker-compose,up -d)

.PHONY: migrate
migrate:
	docker exec -it laradock_workspace_1 /bin/bash -i -c "npm install"
	docker exec -it laradock_workspace_1 /bin/bash -i -c "DISABLE_NOTIFIER=true composer install || true"
	docker exec -it laradock_workspace_1 /bin/bash -i -c "php artisan migrate:refresh --force || true"
	docker exec -it laradock_workspace_1 /bin/bash -i -c "php artisan db:seed --force || true"

.PHONY: test
test:
	docker exec -it laradock_workspace_1 /bin/bash -i -c "composer exec codecept run"

.PHONY: clean
clean:
	$(call docker-compose,stop -t 1)
	$(call docker-compose,rm --force)
