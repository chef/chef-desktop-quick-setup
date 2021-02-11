# Chef Desktop Quick Setup
Set up a demo infrastructure for Chef Desktop in under 15 mins. 

## Table of Contents
  - [Prerequisites](#prerequisites)
    - [Install Terraform](#install-terraform)
    - [Install provider CLI and complete authentication](#install-provider-cli-and-complete-authentication)
      - [AWS CLI](#aws-cli)
    - [Create a terraform input variable file](#create-a-terraform-input-variable-file)
  - [Usage](#usage)
    - [Create Automate 2 server](#create-automate-2-server)
    - [Create a gorilla repository](#create-a-gorilla-repository)
    - [Create virtual nodes](#create-virtual-nodes)
    - [Create a Munki repository](#create-a-munki-repository)
    - [Create all instances at once](#create-all-instances-at-once)

## Prerequisites
To run the modules provided in this repository, we need to install terraform and setup the CLI based on which provider we want to use.

### Install Terraform
Visit https://learn.hashicorp.com/tutorials/terraform/install-cli and install the terraform command line with one of the methods.

### Install provider CLI and complete authentication
#### AWS CLI
We can find installation instructions for AWS CLI 2 at https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html.

### Create a terraform input variable file
Based on the provider, navigate to the directory and create a `terraform.tfvars` file with these variables.
*(You can also use the example values from the `terraform.tfvars.example` file. Copy and paste them.)*

```
admin_username          = *User name for the automate machine*
resource_location       = *Select a resource location*
availability_zone       = *Select the nearest availibility zone*
automate_dns_name_label = *A DNS name label for automate server*
automate_credentials = {
  user_name         = *Name of the client/user that will be created in server*
  user_display_name = *Display name of the client/user*
  user_email        = *Email Address*
  user_password     = *Password*
  org_name          = *Name of the organisation to create*
  org_display_name  = *Display name for organisation*
  validator_path    = *Path to the validator key in virtual nodes relative to chef directory*
}
admin_password_win_node = *Password to set for windows virtual nodes*
```

More information on the variables are available [here](aws/README.md).

## Usage
Once the terraform command line is installed and authenticated to our provider using the CLI, we will start creating the instances.

### Create Automate 2 server
To create an Automate server, open the command line and run the following command:
```bash
terraform apply -target=module.automate
```
That's it! The server will complete installing in a couple of minutes. We can then use the credentials from `keys/automate-credentials.toml`.

> We will also have the client key and validator key downloaded in the same `keys` directory as `<client_name>.pem` and `validator.pem`, respectively.

More details on the variables, resources and outputs, please see [this document](aws/modules/automate/README.md).

### Create a gorilla repository

***-- TODO --***

For more details on the variables, resources, and outputs, please see [this document](aws/modules/gorilla/README.md).

### Create virtual nodes

***-- TODO --***

For more details on the variables, resources, and outputs, please see [this document](aws/modules/nodes/README.md).

### Create a Munki repository

***-- TODO --***

For more details on the variables, resources, and outputs, please see [this document](aws/modules/munki/README.md).

### Create all instances at once

***-- TODO --***

For more details on the variables, resources, and outputs, please see [this document](aws/README.md).