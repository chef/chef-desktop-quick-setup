package test

import (
	"fmt"
	"path"
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)


func configureTerraformOptions(context *testing.T, module string, targets []string) (*terraform.Options)  {
	// Get absolute path to terraform.tfvars.
	variableFilePath, _ := filepath.Abs(fmt.Sprintf("../%s/terraform.tfvars", path.Base(module)))
	// Create terraform options config object
	terraformOptions := terraform.WithDefaultRetryableErrors(context, &terraform.Options{
		TerraformDir: module,
		Targets: targets,
		VarFiles: []string{variableFilePath},
	})

	return terraformOptions
}
