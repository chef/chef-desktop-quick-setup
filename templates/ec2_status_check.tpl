aws configure set default.region ${region}
retries=3
while [[ $retries -gt 0 ]]; do
  aws ec2 wait instance-status-ok --instance-ids ${instance_id}
  [ $? -eq 0 ] && break || :
  retries=$(($retries-1))
done
if [ $retries == 0 ]
then echo "Max retries exceeded. Instance could not be reached."
else echo "Instance ${instance_id} status OK, ready to connect."
fi
