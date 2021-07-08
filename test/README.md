The tests for the terraform scripts have been written in Go using [terratest](https://github.com/gruntwork-io/terratest). Please make sure you have `Go` installed in your system.

### Set up tests

1. Download and Install [Go](https://golang.org)
2. Download all go modules to local.
   ```bash
   cd test
   go mod download
   ```
3. Follow the instructions from [Prerequisites](https://github.com/chef/chef-desktop-quick-setup/wiki/Prerequisites) section of the wiki to set up the local environment.
   1. Download and install Chef Workstation.
   2. Download and install Terraform.
   3. Set up provider CLI
   4. Set up terraform variable file.
4. Depending on what tests you might want to run, you would need to set up the environment appropriately. For example, if we want to test the `munki` module, then we also need to follow instructions for setting up the munki repository along with the setup listed in point 3. Same goes for setting up macOS instances and gorilla setup.

### Running the tests

To run the tests you can either use the `Makefile` at the root of the repository or use the `go test` command directly. The `Makefile` already has some targets you can use. For example, running
```bash
make run_automate_test
```
would run the test for Automate Server setup. This essentially tests if `terraform apply -target=module.automate` completes successfully and runs some checks on the automate server instance, like checking if it returns a 200 response status. Once the test suite completes, it also runs `terraform destroy` for cleanup.

#### Run all tests
*Please make sure you have followed all the instructions from prerequisites for munki and gorilla setup too.*
```bash
make run_tests
```

#### Run test for `automate` module.
```bash
make run_automate_test
```

#### Run test for `nodes` module.
*If you want to include macOS nodes in the tests, please make sure you have followed the instructions for using macOS node given in the wiki pages.*
```bash
make run_virtual_nodes_test
```

#### Run test for `compliance` module.
```bash
make run_compliance_test
```

#### Run test for `munki` module.
*Please make sure you have followed all the instructions from prerequisites for munki setup.*
```bash
make run_munki_test
```

#### Run test for `run_gorilla_test` module.
*Please make sure you have followed all the instructions from prerequisites for gorilla setup.*
```bash
make run_compliance_test
```

We can also run specific tests like so:
```
make run_test target=TestAutomateStandaloneAWS
```
This will run the test for the `automate` module.
