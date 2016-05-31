application_name = "apr"

deploy_user = "deploy"
deploy_home = "/home/#{deploy_user}"

directory "#{deploy_home}/.ssh" do
  owner deploy_user
  recursive true
end

include_recipe "citadel::default"

file "#{deploy_home}/.ssh/deploy_key" do
  content citadel["#{application_name}/deploy_key"]
  owner deploy_user
  mode '0600'
end

cookbook_file "#{deploy_home}/wrap-ssh4git.sh" do
  source 'wrap-ssh4git.sh'
  owner deploy_user
  mode '0755'
end

package "git"

deploy 'apr' do
  repo 'git@github.com:artsy/apr.git'
  user deploy_user
  deploy_to deploy_home
  action :deploy
  ssh_wrapper "#{deploy_home}/wrap-ssh4git.sh"
end

application_env = case node['environment']
when "production"
  "prod"
when "development"
  "dev"
end

execute "get-mix-deps" do
  command "MIX_ENV=#{application_env} yes | mix deps.get"
  cwd "#{deploy_home}/current"
  returns [0, 137]
end

execute "compile-mix-deps" do
  command "MIX_ENV=#{application_env} yes | mix compile"
  cwd "#{deploy_home}/current"
  returns [0, 137]
end

execute "insall-npm-packages" do
  command "npm install"
  cwd "#{deploy_home}/current"
end

command = "mix phoenix.server"
environment = {
  "MIX_ENV" => application_env
}

supervisor_service application_name do
  user deploy_user
  directory "#{deploy_home}/current"
  command command
  stdout_logfile "/var/log/supervisor/#{application_name}.out"
  stderr_logfile "/var/log/supervisor/#{application_name}.err"
  autorestart true
  environment environment
end
