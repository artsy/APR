application_name = "apr"

# include_recipe "citadel::default"
# configuration = citadel["#{node['environment']}/#{application_name}"]

deploy_user = "deploy"
deploy_home = "/home/#{deploy_user}"

nodejs_npm "apr" do
  path "#{deploy_home}/current"
  json true
  user deploy_user
end

command = "mix phoenix.server"
environment = {
  "MIX_ENV" => node['environment']
}

supervisor_service application_name do
  user deploy_user
  directory deploy_home
  command command
  stdout_logfile "/var/log/supervisor/#{application_name}.out"
  stderr_logfile "/var/log/supervisor/#{application_name}.err"
  autorestart true
  environment environment
end
