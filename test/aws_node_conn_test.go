package test

import (
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/shell"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/tidwall/gjson"
)


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
	for index := range nodesTestData.Get("linux_nodes").Array()[:] {
		node_name := fmt.Sprintf("ubuntu-node-%d", index)
		logger.Log(context, fmt.Sprintf("checking if %s exists in the list..", node_name))
		assert.True(context, strings.Contains(stdout, node_name))
	}
}

func testSSHAccessToNodeInstances(context *testing.T, terraformOptions *terraform.Options, nodesOutputData gjson.Result, keypair ssh.KeyPair) {
	// SSH connection configuration
	logger.Log(context, "Checking SSH connections to all nodes..")
	allNodeData := append(nodesOutputData.Get("windows_nodes").Array()[:], nodesOutputData.Get("macos_nodes").Array()[:]...)
	allNodeData = append(allNodeData, nodesOutputData.Get("linux_nodes").Array()[:]...)
	for _, value := range allNodeData {
		sshUserName := ""
		tagName := value.Get("tags.Name").String()
		switch true {
			case strings.Contains(tagName, "macos"):
				sshUserName = "ec2-user"
			case strings.Contains(tagName, "linux"):
				sshUserName = "ubuntu"
			default:
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
