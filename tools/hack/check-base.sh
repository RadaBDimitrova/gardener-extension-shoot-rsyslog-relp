#!/bin/bash

source "$(realpath $(dirname $0))/helper.sh"
dirs=$(filter_existing_dirs $@)

TOOLS_DIR="$(dirname "$TOOLS_HACK_DIR")"
LOGCHECK_DIR="$TOOLS_DIR/logcheck-standalone/bin"
sed $REPO_ROOT/.golangci.yaml.in -e "s#<<LOGCHECK_PLUGIN_PATH>>#$LOGCHECK_DIR#g" > $REPO_ROOT/.golangci.yaml
bash $TOOLS_HACK_DIR/check.sh --golangci-lint-config=$REPO_ROOT/.golangci.yaml $dirs
bash $TOOLS_HACK_DIR/check-skaffold-deps.sh
bash $TOOLS_HACK_DIR/check-charts.sh ./charts