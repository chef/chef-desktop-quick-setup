package test

type AutomateModuleJSONData struct {
	AutomateInstanceID string `json:"automate_instance_id"`
	AutomateServerPublicIP string `json:"automate_server_public_ip"`
	AutomateServerURL string `json:"automate_server_url"`
}

type NodesModuleJSONData struct {
	WindowsNodes []AWSInstance `json:"windows_nodes"`
	MacOSNodes []AWSInstance `json:"macos_nodes"`
	LinuxNodes []AWSInstance `json:"linux_nodes"`
}

type Tags struct {
	Name string `json:"Name"`
}

type AWSInstance struct {
	public_ip string `json:"public_ip"`
	tags Tags `json:"tags"`
}
