run_tests:
	cd test && go test -timeout 60m

run_test:
	cd test && go test -run $(target) -timeout 60m

run_tests_local:
	cd test && export SKIP_teardown=true && go test -timeout 60m

run_automate_test:
	cd test && go test -run TestAutomateStandaloneAWS -timeout 60m

run_virtual_nodes_test:
	cd test && go test -run TestNodesTargetAWS -timeout 60m

run_compliance_test:
	cd test && go test -run TestComplianceTargetAWS -timeout 60m

run_gorilla_test:
	cd test && go test -run TestGorillaTargetAWS -timeout 60m

run_munki_test:
	cd test && go test -run TestMunkiTargetAWS -timeout 60m
