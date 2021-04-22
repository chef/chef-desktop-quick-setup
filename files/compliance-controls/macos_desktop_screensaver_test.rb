title 'Verifying a Screensaver is configured'

control 'Screensaver Check' do
  only_if { os.darwin? }
  impact 'high'
  title 'Verifying that the screensaver has correct idleTime'
  desc 'The control should return value for idleTime'
  describe bash('defaults -currentHost read com.apple.screensaver idleTime') do
    its('stdout') { should be 1200 }
  end
end
