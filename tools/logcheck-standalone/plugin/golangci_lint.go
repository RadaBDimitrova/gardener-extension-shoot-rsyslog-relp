// SPDX-FileCopyrightText: SAP SE or an SAP affiliate company and Gardener contributors
//
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"golang.org/x/tools/go/analysis"

	"github.com/gardener/logcheck/pkg/logcheck"
)

// New returns the logcheck analyzer.
// This is the plugin entry point for golangci-lint.
func New(_ any) ([]*analysis.Analyzer, error) {
	return []*analysis.Analyzer{logcheck.Analyzer}, nil
}
