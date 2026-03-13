#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: SAP SE or an SAP affiliate company and Gardener contributors
#
# SPDX-License-Identifier: Apache-2.0

set -e

source "$(realpath $(dirname $0))/helper.sh"
dirs=$(filter_existing_dirs $@)

echo "> Format"

goimports -l -w $dirs

# Format import order only after files have been formatted by imports.
echo "> Format Import Order"

goimports_reviser_opts=${GOIMPORTS_REVISER_OPTIONS:-""}

for p in "$dirs" ; do
  goimports-reviser $goimports_reviser_opts -recursive $p
done