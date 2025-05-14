SHELL := /bin/bash

ENV_FILE := ../../.env
TERRAFORM := mise exec terraform -- terraform

MODULES := vm-template k8s-cluster

.PHONY: help init apply destroy

help:
	@echo "Usage:"
	@echo "  make init MODULE=<module-name>"
	@echo "  make apply MODULE=<module-name>"
	@echo "  make destroy MODULE=<module-name>"

init:
	@if [ -z "$(MODULE)" ]; then \
		echo "❗ Please provide MODULE=<module-name> (Available: $(MODULES))"; \
		exit 1; \
	fi && \
	cd $(MODULE) && \
	source $(ENV_FILE) && \
	$(TERRAFORM) init

apply:
	@if [ -z "$(MODULE)" ]; then \
		echo "❗ Please provide MODULE=<module-name> (Available: $(MODULES))"; \
		exit 1; \
	fi && \
	cd $(MODULE) && \
	source $(ENV_FILE) && \
	$(TERRAFORM) apply -auto-approve 

destroy:
	@if [ -z "$(MODULE)" ]; then \
		echo "❗ Please provide MODULE=<module-name> (Available: $(MODULES))"; \
		exit 1; \
	fi && \
	cd $(MODULE) && \
	source $(ENV_FILE) && \
	$(TERRAFORM) destroy -auto-approve 
