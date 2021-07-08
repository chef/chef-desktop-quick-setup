package test

import (
	"encoding/json"
	"fmt"
	"strings"
	"time"

	// "fmt"
	"io/ioutil"
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/shell"
	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/tidwall/gjson"
)

func TestNodesTargetAWS(context *testing.T) {
	// context.Parallel()

	// awsModule := test_structure.CopyTerraformFolderToTemp(context, "../", "aws")
	awsModule, err := filepath.Abs("../aws")
	assert.NoError(context, err)

	test_structure.RunTestStage(context, "setup", func() {
		terraformOptions := configureTerraformOptions(context, awsModule, []string{"module.nodes"})
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

		// Get automate and nodes module outputs as JSON string and convert it into struct.
		automateOutputJSONString, err := terraform.OutputJsonE(context, terraformOptions, "automate_module_outputs")
		assert.NoError(context, err)
		nodesOutputJSONString, err := terraform.OutputJsonE(context, terraformOptions, "nodes_module_outputs")
		assert.NoError(context, err)
		automateOutputData := AutomateModuleJSONData{}
		json.Unmarshal([]byte(automateOutputJSONString), &automateOutputData)
		// json.Unmarshal([]byte(nodesOutputJSONString), &nodesOutputData)
		nodesOutputData := gjson.Parse(nodesOutputJSONString)

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

func testNodeListOnServer(context *testing.T, terraformOptions *terraform.Options, nodesTestData gjson.Result) {
	logger.Log(context, "Checking node list on server..")
	stdout, err := shell.RunCommandAndGetStdOutE(context, shell.Command{
		Command: "knife",
		Args: []string{"node", "list"},
		Logger: logger.Discard,
	})
	assert.NoError(context, err)
	for index := range nodesTestData.Get("windows_nodes").Array()[:] {
		node_name := fmt.Sprintf("windowsnode-%d", index)
		logger.Log(context, fmt.Sprintf("checking if %s exists in the list..", node_name))
		assert.True(context, strings.Contains(stdout, node_name))
	}
	if len(nodesTestData.Get("macos_nodes").Array()) == 1 {
		logger.Log(context, "checking if macos-node exists in the list..")
		assert.True(context, strings.Contains(stdout, "macos-node"))
	}
}

func testSSHAccessToNodeInstances(context *testing.T, terraformOptions *terraform.Options, nodesOutputData gjson.Result, keypair ssh.KeyPair) {
	// SSH connection configuration
	logger.Log(context, "Checking SSH connections to all nodes..")
	for _, value := range append(nodesOutputData.Get("windows_nodes").Array()[:], nodesOutputData.Get("macos_nodes").Array()[:]...) {
		sshUserName := ""
		if(strings.Contains(value.Get("tags.Name").String(), "macos")) {
			sshUserName = "ec2-user"
		} else {
			sshUserName = "Administrator"
			// We can't test winRM connection right now with terratest but it may be added in the future.
			continue
		}
		publicHost := ssh.Host{
			Hostname:    value.Get("public_ip").String(),
			SshKeyPair:  &keypair,
			SshUserName:  sshUserName,
		}
		expectedText := "Test String"
		command := fmt.Sprintf("echo -n '%s'", expectedText)
		// Test SSH connection by running a simple echo command and checking the response.
		retry.DoWithRetry(context, fmt.Sprintf("SSH to public host %s", value.Get("public_ip")), 30, 5*time.Second, func() (string, error) {
			actualText, err := ssh.CheckSshCommandE(context, publicHost, command)
			if err != nil {
				return "", err
			}
			if strings.TrimSpace(actualText) != expectedText {
				return "", fmt.Errorf("expected SSH command to return '%s' but got '%s'", expectedText, actualText)
			}
			return "", nil
		})
	}
}
