control 'Screensaver has a Timeout' do
  only_if { os.windows? }
  impact 'high'
  title 'Checking that the Screensaver is set to come on after 20 minutes of inactivity'
  desc 'reading the registry key for ScreenSaveTimeOut'
  describe registry_key('HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Control Panel\Desktop') do
    its(['ScreenSaveTimeOut']) { should eq '1200' }
  end
end
