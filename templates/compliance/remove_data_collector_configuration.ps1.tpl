Write-Host "Updating client cofiguration.."
$UpdatedClientConfiguration = Get-Content -Path C:\chef\client.rb | Where-Object {$_ -notmatch 'data_collector'}
Set-Content -Path C:\chef\client.rb -Value $UpdatedClientConfiguration
Write-Host "Successfully completed client cofiguration update." 
chef-client
