package test

import (
	"io/ioutil"
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestNodesTargetAWS(context *testing.T) {
	// context.Parallel()

	// awsModule := test_structure.CopyTerraformFolderToTemp(context, "../", "aws")
	awsModule, err := filepath.Abs("../aws")
	assert.NoError(context, err)

	test_structure.RunTestStage(context, "setup", func() {
		terraformOptions := ConfigureTerraformOptions(context, awsModule, []string{"module.nodes"})
		test_structure.SaveTerraformOptions(context, awsModule, terraformOptions)

		// Run terraform apply with target as automate
		terraform.InitAndApply(context, terraformOptions)
	})

	test_structure.RunTestStage(context, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(context, awsModule)

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

		// Get automate and nodes module outputs.
		automateOutputData := GetAutomateOutputJSON(context, terraformOptions)
		nodesOutputData := GetNodeOutputJSON(context, terraformOptions)

		// Run tests.
		testSSHAccessToAutomateInstance(context, terraformOptions, automateOutputData, keypair)
		testHTTPAccessToAutomateInstance(context, terraformOptions, automateOutputData)
		testNodeListOnServer(context, terraformOptions, nodesOutputData)
		testSSHAccessToNodeInstances(context, terraformOptions, nodesOutputData, keypair)
	})

	test_structure.RunTestStage(context, "teardown", func() {
		terraformOptions := test_structure.LoadTerraformOptions(context, awsModule)
		// Set target to nil for destroying all the resources.
		terraformOptions.Targets = nil
		terraform.Destroy(context, terraformOptions)
	})
}
