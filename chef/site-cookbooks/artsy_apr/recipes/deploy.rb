deploy_user = "deploy"
deploy_target = "/home/#{deploy_user}/current"

deploy 'apr' do
  repo 'git@github.com:artsy/apr.git'
  user deploy_user
  deploy_to "/home/#{deploy_user}"
  action :deploy
  ssh_wrapper "/home/deploy/wrap-ssh4git.sh"
end

application_env = case node['environment']
when "production"
  "prod"
when "staging"
  "stage"
when "development"
  "dev"
end

environment = {
  "MIX_ENV" => application_env,
  "MIX_HOME" => "/home/deploy/.mix",
  "MIX_ARCHIVES" => "/home/deploy/.mix/archives",
  "HEX_HOME" => "/home/deploy/.hex"
}

execute "get-hex" do
  command "mix local.hex --force"
  user deploy_user
  environment environment
  cwd deploy_target
end

execute "get-rebar" do
  command "mix local.rebar --force"
  user deploy_user
  environment environment
  cwd deploy_target
end

execute "get-mix-deps" do
  command "mix deps.get"
  user deploy_user
  environment environment
  cwd deploy_target
end

execute "compile-mix-deps" do
  command "mix compile"
  user deploy_user
  environment environment
  cwd deploy_target
end

execute "install-npm-packages" do
  command "npm install"
  cwd deploy_target
end

execute "brunch-build" do
  command "node node_modules/brunch/bin/brunch build --production"
  user deploy_user
  cwd deploy_target
end

execute "phoenix-digest" do
  command "mix phoenix.digest"
  user deploy_user
  environment environment
  cwd deploy_target
end

command = "mix phoenix.server"

supervisor_service node[:application_name] do
  user deploy_user
  directory deploy_target
  command command
  stdout_logfile "/var/log/supervisor/#{node[:application_name]}.out"
  stderr_logfile "/var/log/supervisor/#{node[:application_name]}.err"
  autorestart true
  environment environment
end
