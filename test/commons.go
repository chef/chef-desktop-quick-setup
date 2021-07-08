package test

import (
	"crypto/tls"
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Test if the user can access the dashboard from a browser.
func testHTTPAccessToAutomateInstance(context *testing.T, terraformOptions *terraform.Options, automateOutputData AutomateModuleJSONData)  {
	// Read aws region from var file.
	awsRegion, err := terraform.GetVariableAsStringFromVarFileE(context, terraformOptions.VarFiles[0], "resource_location")
	assert.NoError(context, err)
	// Get public IP of the instance from AWS and compare it to the passed output.
	instancePublicIP, err := aws.GetPublicIpOfEc2InstanceE(context, automateOutputData.AutomateInstanceID, awsRegion)
	assert.NoError(context, err)
	assert.Equal(context, automateOutputData.AutomateServerPublicIP, instancePublicIP)
	// Make an http request to the automate instance and check response status.
	url := fmt.Sprintf("https://%s", automateOutputData.AutomateServerURL)
	retry.DoWithRetry(context, fmt.Sprintf("HTTP Get to server URL %s", automateOutputData.AutomateServerURL), 30, 5*time.Second, func ()(string, error)  {
		automateServerResponseStatus, _, err := http_helper.HttpGetE(context, url, &tls.Config{
			InsecureSkipVerify: true, // Skip certificate check for tests.
		})
		if(err != nil) {
			return "", err
		}
		if(automateServerResponseStatus != 200) {
			return "", fmt.Errorf("expected response status to be %d but got %d", 200, automateServerResponseStatus)
		}
		return "", nil
	})
}

func testSSHAccessToAutomateInstance(context *testing.T, terraformOptions *terraform.Options, automateOutputData AutomateModuleJSONData, keypair ssh.KeyPair)  {
	// SSH connection configuration
	publicHost := ssh.Host{
		Hostname: automateOutputData.AutomateServerPublicIP,
		SshKeyPair: &keypair,
		SshUserName: "ubuntu",
	}
	expectedText := "Test String"
	command := fmt.Sprintf("echo -n '%s'", expectedText)
	// Test SSH connection by running a simple echo command and checking the response.
	retry.DoWithRetry(context, fmt.Sprintf("SSH to public host %s", automateOutputData.AutomateServerPublicIP), 30, 5*time.Second, func()(string, error) {
		actualText, err := ssh.CheckSshCommandE(context, publicHost, command)
		if(err != nil) {
			return "", err
		}
		if(strings.TrimSpace(actualText) != expectedText) {
			return "", fmt.Errorf("expected SSH command to return '%s' but got '%s'", expectedText, actualText)
		}
		return "", nil
	})
}
