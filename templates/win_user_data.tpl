<powershell>
# Set admin password.
$admin = [adsi]("WinNT://./administrator, user")
$admin.psbase.invoke("SetPassword", "${admin_password}")
#  Configure winrm
winrm quickconfig -q
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="1024"}'
# Allow winrm connection from anywhere in firewall
netsh advfirewall firewall add rule name="WinRM in" protocol=TCP dir=in profile=any localport=5985 remoteip=any localip=any action=allow
# Stop the WinRM service, make sure it autostarts on reboot, and start it
net stop winrm
sc.exe config winrm start=auto
net start winrm
</powershell>