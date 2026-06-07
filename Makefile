SHELL := /bin/bash

PACKAGE ?= aws-crossplane-stack
XRD_DIR := apis/crossplanestacks
COMPOSITION := $(XRD_DIR)/composition.yaml
DEFINITION := $(XRD_DIR)/definition.yaml
CONFIGURATION := $(XRD_DIR)/configuration.yaml
EXAMPLE_DEFAULT := examples/crossplanestacks/standard.yaml
RENDER_TESTS := $(wildcard tests/test-*)
E2E_TESTS := $(wildcard tests/e2etest-*)
API_DIRS := $(sort $(dir $(wildcard apis/*/definition.yaml)))

clean:
	rm -rf _output
	rm -rf .up
	rm -f $(API_DIRS:%=%configuration.yaml)

build:
	up project build

generate-configuration:
	@set -euo pipefail; \
	rm -f $(API_DIRS:%=%configuration.yaml); \
	hops validate generate-configuration --path . --api-path "$(XRD_DIR)"

# Examples list - mirrors GitHub Actions workflow
# Format: example_path::observed_resources_path (observed_resources_path is optional)
EXAMPLES := \
    examples/crossplanestacks/minimal.yaml:: \
    examples/crossplanestacks/standard.yaml:: \
    examples/crossplanestacks/full.yaml:: \
    examples/awsproviderstacks/minimal.yaml:: \
    examples/awsproviderstacks/full.yaml:: \
    examples/functionsstacks/minimal.yaml:: \
    examples/functionsstacks/full.yaml:: \
    examples/githubproviderstacks/minimal.yaml:: \
    examples/githubproviderstacks/full.yaml:: \
    examples/helmproviderstacks/minimal.yaml:: \
    examples/helmproviderstacks/full.yaml:: \
    examples/kubernetesproviderstacks/minimal.yaml:: \
    examples/kubernetesproviderstacks/full.yaml:: \
    examples/listmonkproviderstacks/minimal.yaml:: \
    examples/listmonkproviderstacks/full.yaml:: \
    examples/openpanelproviderstacks/minimal.yaml:: \
    examples/openpanelproviderstacks/full.yaml:: \
    examples/zitadelproviderstacks/minimal.yaml:: \
    examples/zitadelproviderstacks/full.yaml::

# Render all examples.
render\:all:
	@set -euo pipefail; \
	for entry in $(EXAMPLES); do \
		example=$${entry%%::*}; \
		observed=$${entry#*::}; \
		api_dir=$$(echo "$$example" | awk -F/ '{print "apis/" $$2}'); \
		composition="$$api_dir/composition.yaml"; \
		definition="$$api_dir/definition.yaml"; \
		if [ -n "$$observed" ]; then \
			echo "=== Rendering $$example with observed-resources $$observed ==="; \
			up composition render --xrd=$$definition $$composition $$example --observed-resources=$$observed; \
		else \
			echo "=== Rendering $$example (api=$$api_dir) ==="; \
			up composition render --xrd=$$definition $$composition $$example; \
		fi; \
		echo ""; \
	done

# Validate all examples.
validate\:all: generate-configuration
	@set -euo pipefail; \
	for entry in $(EXAMPLES); do \
		example=$${entry%%::*}; \
		observed=$${entry#*::}; \
		api_dir=$$(echo "$$example" | awk -F/ '{print "apis/" $$2}'); \
		composition="$$api_dir/composition.yaml"; \
		definition="$$api_dir/definition.yaml"; \
		if [ -n "$$observed" ]; then \
			echo "=== Validating $$example with observed-resources $$observed ==="; \
			up composition render --xrd=$$definition $$composition $$example \
				--observed-resources=$$observed --include-full-xr --quiet | \
				crossplane beta validate $(CONFIGURATION),$$api_dir --error-on-missing-schemas -; \
		else \
			echo "=== Validating $$example (api=$$api_dir) ==="; \
			up composition render --xrd=$$definition $$composition $$example \
				--include-full-xr --quiet | \
				crossplane beta validate $(CONFIGURATION),$$api_dir --error-on-missing-schemas -; \
		fi; \
		echo ""; \
	done

# Shorthand aliases
.PHONY: render validate generate-configuration print-examples
render: ; @$(MAKE) 'render:all'
validate: ; @$(MAKE) generate-configuration 'validate:all'
print-examples:
	@printf '%s\n' $(EXAMPLES)

# Single example targets
render\:%:
	@example="examples/crossplanestacks/$*.yaml"; \
	up composition render --xrd=$(DEFINITION) $(COMPOSITION) $$example

validate\:%: generate-configuration
	@example="examples/crossplanestacks/$*.yaml"; \
	up composition render --xrd=$(DEFINITION) $(COMPOSITION) $$example \
		--include-full-xr --quiet | \
		crossplane beta validate $(CONFIGURATION),$(XRD_DIR) --error-on-missing-schemas -

test:
	up test run $(RENDER_TESTS)

e2e:
	up test run $(E2E_TESTS) --e2e

publish:
	@if [ -z "$(tag)" ]; then echo "Error: tag is not set. Usage: make publish tag=<version>"; exit 1; fi
	up project build --push --tag $(tag)
