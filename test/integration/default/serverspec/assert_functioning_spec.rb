require 'serverspec'

set :backend, :exec

describe service('casa-default') do
  it { should be_enabled }
  it { should be_running }
end

describe command('curl http://localhost:3000') do
  its(:stdout) { should match(%r{<title>CASA On Rails<\/title>}) }
end
