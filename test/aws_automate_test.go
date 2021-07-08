package test

import (
	"encoding/json"
	"io/ioutil"
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)


func TestAutomateStandaloneAWS(context *testing.T) {
	// context.Parallel()

	awsModule := test_structure.CopyTerraformFolderToTemp(context, "../", "aws")
	tmpFile, err := ioutil.TempFile("", "test-data-temp-file")
	assert.NoError(context, err)
	
	test_structure.RunTestStage(context, "setup", func ()  {
		terraformOptions := configureTerraformOptions(context, awsModule, []string{"module.automate"})
		test_structure.SaveTerraformOptions(context, awsModule, terraformOptions)
		
		// Run terraform apply with target as automate
		terraform.InitAndApply(context, terraformOptions)
		
		// Get automate module outputs as JSON string and convert it into struct.
		outputJSONString, err := terraform.OutputJsonE(context, terraformOptions, "automate_module_outputs")
		assert.NoError(context, err)
		automateOutputData := AutomateModuleJSONData{}
		json.Unmarshal([]byte(outputJSONString), &automateOutputData)
		// Save to test data.
		assert.False(context, test_structure.IsTestDataPresent(context, tmpFile.Name()), "Expected test data file to be empty")
		test_structure.SaveTestData(context, tmpFile.Name(), automateOutputData)
	})

	test_structure.RunTestStage(context, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(context, awsModule)

		// Load saved test data.
		var moduleOutputs AutomateModuleJSONData
		test_structure.LoadTestData(context, tmpFile.Name(), &moduleOutputs)

		// Read public key from local
		publicKeyRelPath, err := terraform.GetVariableAsStringFromVarFileE(context, terraformOptions.VarFiles[0], "public_key_path")
		assert.NoError(context, err)
		publicKeyPath, _ := filepath.Abs(publicKeyRelPath)
		publicKey, _ := ioutil.ReadFile(publicKeyPath)
		
		// Read private key from local
		privateKeyRelPath, err := terraform.GetVariableAsStringFromVarFileE(context, terraformOptions.VarFiles[0], "private_key_path")
		assert.NoError(context, err)
		privateKeyPath, _ := filepath.Abs(privateKeyRelPath)
		privateKey, _ := ioutil.ReadFile(privateKeyPath)
		
		// Create keypair struct
		// NOTE: Should we create a new keypair with aws.CreateAndImportEC2KeyPairE and later delete it on teardown phase?
		keypair := ssh.KeyPair{PublicKey: string(publicKey), PrivateKey: string(privateKey)}

		// Run tests.
		testSSHAccessToAutomateInstance(context, terraformOptions, moduleOutputs, keypair)
		testHTTPAccessToAutomateInstance(context, terraformOptions, moduleOutputs)
	})

	test_structure.RunTestStage(context, "teardown", func ()  {
		terraformOptions := test_structure.LoadTerraformOptions(context, awsModule)
		// Set target to nil for destroying all the resources.
		terraformOptions.Targets = nil
		terraform.Destroy(context, terraformOptions)
	})
}
