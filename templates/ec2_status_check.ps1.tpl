aws configure set default.region ${region}
$retries=3
while($retries -gt 0) {
  aws ec2 wait instance-status-ok --instance-ids ${instance_id}
  If($LASTEXITCODE -eq 0) { break } else {}
  $retries = $retries - 1
}
If ($retries -eq 0) {
 echo "Max retries exceeded. MacOS instance could not be reached."
} else {
 echo "MacOS Instance ${instance_id} status OK, ready to connect."
}