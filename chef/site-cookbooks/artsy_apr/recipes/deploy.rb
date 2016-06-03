deploy_user = "deploy"
deploy_target = "/home/#{deploy_user}/current"
application_name = node[:application_name]
configuration = node["artsy"]["config"][application_name]

include_recipe "citadel::default"

secrets = citadel["#{node[:application_name]}/#{node['environment']}"]

deploy application_name do
  repo configuration["deployment"]["repo"]
  branch configuration["deployment"]["branch"]
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

unless configuration["environment"].nil?
  environment.merge! configuration["environment"]
end
unless secrets["application"]["environment"].nil?
  environment.merge! secrets["application"]["environment"]
end

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

supervisor_service application_name do
  user deploy_user
  directory deploy_target
  command command
  stdout_logfile "/var/log/supervisor/#{application_name}.out"
  stdout_logfile_maxbytes '50MB'
  stdout_logfile_backups 5
  stderr_logfile "/var/log/supervisor/#{application_name}.err"
  stderr_logfile_maxbytes '50MB'
  stderr_logfile_backups 5
  autorestart true
  environment environment
end