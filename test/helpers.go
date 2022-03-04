package test

import (
	"encoding/json"
	"fmt"
	"path"
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/tidwall/gjson"
)


func ConfigureTerraformOptions(context *testing.T, module string, targets []string) (*terraform.Options)  {
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

func GetNodeOutputJSON(context *testing.T, options *terraform.Options) (nodesOutputData gjson.Result) {
		nodesOutputJSONString, err := terraform.OutputJsonE(context, options, "nodes_module_outputs")
		assert.NoError(context, err)
		
		nodesOutputData = gjson.Parse(nodesOutputJSONString)
		return
}

func GetAutomateOutputJSON(context *testing.T, options *terraform.Options) (automateOutputData AutomateModuleJSONData) {
			automateOutputJSONString, err := terraform.OutputJsonE(context, options, "automate_module_outputs")
			assert.NoError(context, err)
			json.Unmarshal([]byte(automateOutputJSONString), &automateOutputData)
			return
}
