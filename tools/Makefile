# VERSION := $(shell cat VERSION)
EFFECTIVE_VERSION ?= $(VERSION)-$(shell git rev-parse --short HEAD)

ifneq ($(strip $(shell git status --porcelain 2>/dev/null)),)
	EFFECTIVE_VERSION := $(EFFECTIVE_VERSION)-dirty
endif

IMAGE_TAG ?= $(EFFECTIVE_VERSION)

# Get the currently used golang install path (in GOPATH/bin, unless GOBIN is set)
ifeq (,$(shell go env GOBIN))
GOBIN=$(shell go env GOPATH)/bin
else
GOBIN=$(shell go env GOBIN)
endif

GOOS = $(shell go env GOOS)
GOARCH = $(shell go env GOARCH)

# CONTAINER_TOOL defines the container tool to be used for building images.
# Be aware that the target commands are only tested with Docker which is
# scaffolded by default. However, you might want to replace it to use other
# tools. (i.e. podman)
CONTAINER_TOOL ?= docker

# Setting SHELL to bash allows bash commands to be executed by recipes.
# Options are set to exit when a recipe line exits non-zero or a piped command fails.
SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec

REPO_ROOT                         ?= $(shell git rev-parse --show-toplevel)
MAKEFILE_DIR                      := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
TOOLS_HACK_DIR 				      := $(MAKEFILE_DIR)/hack
TOOLS_BIN_DIR                     ?= $(LOCALBIN)
DIRS 							  ?= ./cmd ./pkg ./test
REC_DIRS 						  ?= ./cmd/... ./pkg/... ./test/...
TEST_DIRS						  ?= ./cmd/... ./pkg/...
DEFAULT_MANIFESTS_DIRS            ?= charts cmd example extensions imagevector pkg plugin test third_party
GENERATE_WHAT					  ?= protobuf codegen manifests logcheck
LOGCHECK_DIR := $(MAKEFILE_DIR)/logcheck-standalone

## Rules
tools-for-generate: controller-gen golangci-lint goimports yq

.PHONY: all
all: build

HI ?= $(MAKEFILE_DIR)/hi.sh
.PHONY: hi
hi:
	@bash $(HI)

##@ General

# The help target prints out all targets with their descriptions organized
# beneath their categories. The categories are represented by '##@' and the
# target descriptions by '##'. The awk command is responsible for reading the
# entire set of makefiles included in this invocation, looking for lines of the
# file as xyz: ## something, and then pretty-format the target and help. Then,
# if there's a line with ##@ something, that gets pretty-printed as a category.
# More info on the usage of ANSI control characters for terminal formatting:
# https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_parameters
# More info on the awk command:
# http://linuxcommand.org/lc3_adv_awk.php

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ wip
LOCAL_SCRIPTS_DIR ?= $(shell git rev-parse --show-toplevel)/hack

# Convention:
# - shared script:   tools/hack/<target>.sh
# - local override:  hack/<target>.sh   (runs instead of shared if exists)
# Usage: $(call run_target,<name>,<args>,<env vars>)
define run_target
@if [ -f "$(LOCAL_SCRIPTS_DIR)/$(1).sh" ]; then \
    echo "Running local override: $(LOCAL_SCRIPTS_DIR)/$(1).sh"; \
    TOOLS_HACK_DIR=$(TOOLS_HACK_DIR) REPO_ROOT=$(REPO_ROOT) $(3) $(SHELL) "$(LOCAL_SCRIPTS_DIR)/$(1).sh" $(2); \
else \
    echo "Running shared script: $(TOOLS_HACK_DIR)/$(1).sh"; \
    TOOLS_HACK_DIR=$(TOOLS_HACK_DIR) REPO_ROOT=$(REPO_ROOT) $(3) $(SHELL) "$(TOOLS_HACK_DIR)/$(1).sh" $(2); \
fi
endef


##@ Development

.PHONY: generate
generate: tools-for-generate
	$(call run_target,generate,,WHAT="$(GENERATE_WHAT)" DEFAULT_MANIFESTS_DIRS="$(DEFAULT_MANIFESTS_DIRS)" TOOLS_BIN_DIR="$(TOOLS_BIN_DIR)" MAX_PARALLEL_WORKERS=1)


# define GENERATE_HELP_INFO
# # Usage: make generate [WHAT="<targets>"] [MODE="<mode>"] [CODEGEN_GROUPS="<groups>"] [MANIFESTS_DIRS="<folders>"] [MAX_PARALLEL_WORKERS="<num>"]
# #
# # Options:
# #   WHAT                   - Specify the targets to run (e.g., "protobuf codegen manifests logcheck")
# #   CODEGEN_GROUPS         - Specify which groups to run the 'codegen' target for, not applicable for other targets (e.g., "authentication_groups core_groups extensions_groups resources_groups
# #                            operator_groups seedmanagement_groups operations_groups settings_groups operatorconfig_groups controllermanager_groups admissioncontroller_groups scheduler_groups
# #                            gardenlet_groups resourcemanager_groups shoottolerationrestriction_groups shootdnsrewriting_groups shootresourcereservation_groups provider_local_groups extensions_config_groups")
# #   MANIFESTS_DIRS         - Specify which directories to run the 'manifests' target in, not applicable for other targets (Default directories are "charts cmd example extensions imagevector pkg plugin test")
# #   MODE                   - Specify the mode for the 'manifests' (default=parallel) or 'codegen' (default=sequential) target (e.g., "parallel" or "sequential")
# #   MAX_PARALLEL_WORKERS   - Specify the number of maximum parallel workers that will be used when MODE='parallel' (default=4)
# #
# # Examples:
# #   make generate
# #   make generate WHAT="codegen protobuf"
# #   make generate WHAT="codegen protobuf" MODE="sequential"
# #   make generate WHAT="manifests" MANIFESTS_DIRS="pkg/component plugin" MODE="sequential"
# #   make generate WHAT="codegen" CODEGEN_GROUPS="core_groups extensions_groups"
# #   make generate WHAT="codegen manifests" CODEGEN_GROUPS="operator_groups controllermanager_groups" MANIFESTS_DIRS="charts extensions/pkg"
# #   make generate WHAT="manifests" MAX_PARALLEL_WORKERS=8
# #
# endef
# export GENERATE_HELP_INFO
# .PHONY: generate
# ifeq ($(PRINT_HELP),y)
# generate:
# 	@echo "$$GENERATE_HELP_INFO"
# else
# generate: tools-for-generate
# 	@printf "\nFor more info on the generate command, Run 'make generate PRINT_HELP=y'\n"
# 	@REPO_ROOT=$(REPO_ROOT) LOGCHECK_DIR=$(LOGCHECK_DIR) hack/generate.sh --what "$(WHAT)" --codegen-groups "$(CODEGEN_GROUPS)" --manifests-dirs "$(MANIFESTS_DIRS)" --mode "$(MODE)" --max-parallel-workers "$(MAX_PARALLEL_WORKERS)"
# 	$(MAKE) format
# endif


# should these be generic?
# .PHONY: generate-extension
# generate-extension: $(EXTENSION_GEN) $(KUSTOMIZE)
# 	@bash $(TOOLS_HACK_DIR)/generate-sequential.sh ./example/...

# .PHONY: generate-controller-registration
# generate-controller-registration:
# 	@bash $(TOOLS_HACK_DIR)/generate-sequential.sh ./charts/...

.PHONY: format
format: goimports goimports-reviser
	$(call run_target,format,$(DIRS))

.PHONY: sast
sast: gosec
	$(call run_target,sast)

.PHONY: sast-report
sast-report: gosec
	$(call run_target,sast,--gosec-report true)

.PHONY: test
test: envtest  ## Run tests.
	$(call run_target,test,$(TEST_DIRS))

.PHONY: test-cov
test-cov:
	$(call run_target,test-cover,$(TEST_DIRS))

.PHONY: test-cov-clean
test-cov-clean:
	$(call run_target,test-cover-clean)

.PHONY: check-generate
check-generate: tools-for-generate
	$(call run_target,check-generate,$(REPO_ROOT))

.PHONY: check
check: tools-for-generate $(LOGCHECK)
	$(call run_target,check-base,$(REC_DIRS),\
	SKAFFOLD_FILE=$(SKAFFOLD_FILE) \
	SKAFFOLD_BINARY=$(SKAFFOLD_BINARY) \
	SKAFFOLD_CONFIG=$(SKAFFOLD_CONFIG))

# could be added, but unnecessary right now (diff with gardener)
# 	@hack/check-imports.sh ./charts/... ./cmd/... ./extensions/... ./pkg/... ./plugin/... ./test/...
# 	@echo "> Check $(LOGCHECK_DIR)"
# 	@cd $(LOGCHECK_DIR); $(abspath $(GOLANGCI_LINT)) run -c $(REPO_ROOT)/.golangci.yaml --timeout 10m ./...
# 	@cd $(LOGCHECK_DIR); go vet ./...
# 	@cd $(LOGCHECK_DIR); $(abspath $(GOIMPORTS)) -l .
# 	@hack/check-license-header.sh
# 	@hack/check-plutono-dashboards.sh
# 	@hack/check-typos.sh
# 	@hack/check-file-names.sh

.PHONY: clean
clean:
	$(call run_target,clean,$(REC_DIRS))

# wip
.PHONY: tidy
tidy:
	@GO111MODULE=on go mod tidy
	@cd $(LOGCHECK_DIR); go mod tidy
#   @GARDENER_HACK_DIR=$(TOOLS_HACK_DIR) bash $(HACK_DIR)/update-github-templates.sh

.PHONY: verify
verify: check format test sast

.PHONY: verify-extended
verify-extended: check-generate check format test-cov test-cov-clean sast-report

.PHONY: lint-fix
lint-fix: golangci-lint ## Run golangci-lint linter and perform fixes
	$(GOLANGCI_LINT) run --fix

##@ Build

.PHONY: build
build: generate ## Build manager binary.
	go build -o bin/manager cmd/main.go

.PHONY: run
run: generate ## Run a controller from your host.
	go run ./cmd/main.go

# If you wish to build the manager image targeting other platforms you can use the --platform flag.
# (i.e. docker build --platform linux/arm64). However, you must enable docker buildKit for it.
# More info: https://docs.docker.com/develop/develop-images/build_enhancements/
.PHONY: docker-build
docker-build: ## Build docker image with the manager.
	$(CONTAINER_TOOL) build -t ${IMG}:${IMAGE_TAG} .

.PHONY: docker-push
docker-push: ## Push docker image with the manager.
	$(CONTAINER_TOOL) push ${IMG}:${IMAGE_TAG}

##@ Dependencies

## Location to install dependencies to
LOCALBIN ?= $(shell pwd)/bin
LOCALHACK ?= $(TOOLS_HACK_DIR)
export PATH := $(abspath $(LOCALBIN)):$(PATH)
$(LOCALBIN):
	mkdir -p $(LOCALBIN)

## Tool Binaries
KUSTOMIZE ?= $(LOCALBIN)/kustomize
CONTROLLER_GEN ?= $(LOCALBIN)/controller-gen
ENVTEST ?= $(LOCALBIN)/setup-envtest
GOLANGCI_LINT = $(LOCALBIN)/golangci-lint
MINIKUBE ?= $(LOCALBIN)/minikube
YQ ?= $(LOCALBIN)/yq
HELM ?= $(LOCALBIN)/helm
KIND ?= $(LOCALBIN)/kind
SKAFFOLD ?= $(LOCALBIN)/skaffold
KUBECTL ?= $(LOCALBIN)/kubectl
SAST ?= $(LOCALHACK)/sast.sh
GOSEC ?= $(LOCALBIN)/gosec
INSTALL_GOSEC ?= $(LOCALHACK)/install-gosec.sh
GOIMPORTS ?= $(LOCALBIN)/goimports
GOIMPORTSREVISER ?= $(LOCALBIN)/goimports-reviser
LOGCHECK ?= $(LOCALBIN)/logcheck.so
EXTENSION_GEN ?= $(LOCALBIN)/extension-generator
GEN_CRD_API_REFERENCE_DOCS ?= $(LOCALBIN)/gen-crd-api-reference-docs
GINKGO ?= $(LOCALBIN)/ginkgo

## Tool Versions
KUSTOMIZE_VERSION ?= v5.5.0
CONTROLLER_TOOLS_VERSION ?= v0.19.0
ENVTEST_VERSION ?= release-0.19
GOLANGCI_LINT_VERSION ?= v2.7.2
MINIKUBE_VERSION ?= v1.34.0
YQ_VERSION ?= v4.44.3
HELM_VERSION ?= v3.16.2
KIND_VERSION ?= v0.30.0
SKAFFOLD_VERSION ?= v2.16.1
KUBECTL_VERSION ?= v1.33.4
GOSEC_VERSION ?= v2.22.10
GOIMPORTS_VERSION ?= v0.38.0
GOIMPORTSREVISER_VERSION ?= v3.11.0

# minikube settings
MINIKUBE_PROFILE ?= pvc-autoscaler
MINIKUBE_DRIVER ?= qemu

# A target which is used to clean up previous versions of tools
$(LOCALBIN)/.version_%: | $(LOCALBIN)
	@file=$@; rm -f $${file%_*}*
	@touch $@

# gen-tool-version adds a prereq to a tool target with the given version
# $1 - target binary path
# $2 - version of the tool
gen-tool-version = $(LOCALBIN)/.version_$(subst $(LOCALBIN)/,,$(1))_$(2)

.PHONY: kustomize
kustomize: $(KUSTOMIZE) | $(LOCALBIN)  ## Download kustomize locally if necessary.
$(KUSTOMIZE): $(call gen-tool-version,$(KUSTOMIZE),$(KUSTOMIZE_VERSION))
	$(call go-install-tool,$(KUSTOMIZE),sigs.k8s.io/kustomize/kustomize/v5,$(KUSTOMIZE_VERSION))

.PHONY: helm
helm: $(HELM) | $(LOCALBIN)  ## Download helm locally if necessary.
$(HELM): $(call gen-tool-version,$(HELM),$(HELM_VERSION))
	curl -L -o - \
		https://get.helm.sh/helm-$(HELM_VERSION)-$(GOOS)-$(GOARCH).tar.gz | \
		tar zxvf - -C $(LOCALBIN) --strip-components=1 $(GOOS)-$(GOARCH)/helm
	touch $(HELM) && chmod +x $(HELM)

.PHONY: minikube
minikube: $(MINIKUBE) | $(LOCALBIN)  ## Download minikube locally if necessary.
$(MINIKUBE): $(call gen-tool-version,$(MINIKUBE),$(MINIKUBE_VERSION))
	$(call download-tool,minikube,https://github.com/kubernetes/minikube/releases/download/$(MINIKUBE_VERSION)/minikube-$(GOOS)-$(GOARCH))

.PHONY: controller-gen
controller-gen: $(CONTROLLER_GEN) | $(LOCALBIN)  ## Download controller-gen locally if necessary.
$(CONTROLLER_GEN): $(call gen-tool-version,$(CONTROLLER_GEN),$(CONTROLLER_TOOLS_VERSION))
	$(call go-install-tool,$(CONTROLLER_GEN),sigs.k8s.io/controller-tools/cmd/controller-gen,$(CONTROLLER_TOOLS_VERSION))

.PHONY: envtest
envtest: $(ENVTEST) | $(LOCALBIN) ## Download setup-envtest locally if necessary.
$(ENVTEST): $(call gen-tool-version,$(ENVTEST),$(ENVTEST_VERSION))
	$(call go-install-tool,$(ENVTEST),sigs.k8s.io/controller-runtime/tools/setup-envtest,$(ENVTEST_VERSION))

.PHONY: golangci-lint
golangci-lint: $(GOLANGCI_LINT) | $(LOCALBIN)  ## Download golangci-lint locally if necessary.
$(GOLANGCI_LINT): $(call gen-tool-version,$(GOLANGCI_LINT),$(GOLANGCI_LINT_VERSION))
	$(call go-install-tool,$(GOLANGCI_LINT),github.com/golangci/golangci-lint/v2/cmd/golangci-lint,$(GOLANGCI_LINT_VERSION))

.PHONY: yq
yq: $(YQ) | $(LOCALBIN)  ## Download yq locally if necessary.
$(YQ): $(call gen-tool-version,$(YQ),$(YQ_VERSION))
	$(call download-tool,yq,https://github.com/mikefarah/yq/releases/download/$(YQ_VERSION)/yq_$(GOOS)_$(GOARCH))

.PHONY: kind
kind: $(KIND) | $(LOCALBIN)  ## Download kind locally if necessary.
$(KIND): $(call gen-tool-version,$(KIND),$(KIND_VERSION))
	$(call download-tool,kind,https://kind.sigs.k8s.io/dl/$(KIND_VERSION)/kind-$(GOOS)-$(GOARCH))

.PHONY: skaffold
skaffold: $(SKAFFOLD) | $(LOCALBIN)  ## Download skaffold locally if necessary.
$(SKAFFOLD): $(call gen-tool-version,$(SKAFFOLD),$(SKAFFOLD_VERSION))
		$(call download-tool,skaffold,https://storage.googleapis.com/skaffold/releases/$(SKAFFOLD_VERSION)/skaffold-$(GOOS)-$(GOARCH))

.PHONY: gosec
gosec: $(GOSEC) | $(LOCALHACK)
$(GOSEC): $(call tool_version_file,$(GOSEC),$(GOSEC_VERSION))
	@GOSEC_VERSION=$(GOSEC_VERSION) TOOLS_BIN_DIR=$(LOCALBIN) bash $(LOCALHACK)/install-gosec.sh

.PHONY: kubectl
kubectl: $(KUBECTL) | $(LOCALBIN)  ## Download kubectl locally if necessary.
$(KUBECTL): $(call gen-tool-version,$(KUBECTL),$(KUBECTL_VERSION))
		$(call download-tool,kubectl,https://dl.k8s.io/release/$(KUBECTL_VERSION)/bin/$(GOOS)/$(GOARCH)/kubectl)

.PHONY: goimports
goimports: $(GOIMPORTS) | $(LOCALBIN)  ## Download goimports locally if necessary.
$(GOIMPORTS): $(call gen-tool-version,$(GOIMPORTS),$(GOIMPORTS_VERSION))
	$(call go-install-tool,$(GOIMPORTS),golang.org/x/tools/cmd/goimports,$(GOIMPORTS_VERSION))

.PHONY: goimports-reviser
goimports-reviser: $(GOIMPORTSREVISER) | $(LOCALBIN)  ## Download goimports-reviser locally if necessary.
$(GOIMPORTSREVISER): $(call gen-tool-version,$(GOIMPORTSREVISER),$(GOIMPORTSREVISER_VERSION))
	$(call go-install-tool,$(GOIMPORTSREVISER),github.com/incu6us/goimports-reviser/v3,$(GOIMPORTSREVISER_VERSION))

.PHONY: extension-generator
extension-generator: $(EXTENSION_GEN) | $(LOCALBIN)  ## Build extension-generator locally if necessary.
$(EXTENSION_GEN): go.mod
	go build -o $(EXTENSION_GEN) github.com/gardener/gardener/hack/tools/extension-generator

.PHONY: gen-crd-api-reference-docs
gen-crd-api-reference-docs: $(GEN_CRD_API_REFERENCE_DOCS) | $(LOCALBIN)  ## Build gen-crd-api-reference-docs locally if necessary.
$(GEN_CRD_API_REFERENCE_DOCS): go.mod
	go build -o $(GEN_CRD_API_REFERENCE_DOCS) github.com/ahmetb/gen-crd-api-reference-docs

.PHONY: ginkgo
ginkgo: $(GINKGO) | $(LOCALBIN)  ## Build ginkgo locally if necessary.
$(GINKGO): go.mod
	go build -o $(GINKGO) github.com/onsi/ginkgo/v2/ginkgo

ifeq ($(strip $(shell go list -m 2>/dev/null)),github.com/gardener/gardener)
$(LOGCHECK): $(TOOLS_PKG_PATH)/logcheck/go.* $(shell find $(TOOLS_PKG_PATH)/logcheck -type f -name '*.go')
	cd $(TOOLS_PKG_PATH)/logcheck;GOTOOLCHAIN=auto CGO_ENABLED=1 go build -o $(abspath $(LOGCHECK)) -buildmode=plugin ./plugin
else
$(LOGCHECK): go.mod
	cd $(shell go list -f '{{ .Dir }}' github.com/gardener/gardener/hack/tools/logcheck); GOTOOLCHAIN=auto CGO_ENABLED=1 go build -o $(LOGCHECK) -buildmode=plugin ./plugin
endif

# go-install-tool will 'go install' any package with custom target and name of binary, if it doesn't exist
#
# $1 - target path with name of binary (ideally with version)
# $2 - package url which can be installed
# $3 - specific version of package
define go-install-tool
@set -e; \
package=$(2)@$(3) ;\
echo "Downloading $${package}" ;\
GOBIN=$(LOCALBIN) go install $${package}
endef

# download-tool will download a binary package from the given URL.
#
# $1 - name of the tool
# $2 - HTTP URL to download the tool from
define download-tool
@set -e; \
tool=$(1) ;\
echo "Downloading $${tool}" ;\
curl -o $(LOCALBIN)/$(1) -sSfL $(2) ;\
chmod +x $(LOCALBIN)/$(1)
endef


