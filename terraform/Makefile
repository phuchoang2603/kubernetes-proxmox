SHELL := /bin/bash

ROOT_DIR := $(shell git rev-parse --show-toplevel)
TERRAFORM := mise exec terraform -- terraform
.PHONY: help init apply destroy

help:
	@echo "Usage:"
	@echo "  make init MODULE=<module-name>"
	@echo "  make apply MODULE=<module-name>"
	@echo "  make destroy MODULE=<module-name>"

init:
	cd $(MODULE) && \
	$(TERRAFORM) init -reconfigure -backend-config="$(ROOT_DIR)/config/$(TF_VAR_env).s3.tfbackend" || $(TERRAFORM) init

apply:
	cd $(MODULE) && \
	$(TERRAFORM) apply -auto-approve 

destroy:
	cd $(MODULE) && \
	$(TERRAFORM) destroy -auto-approve 
