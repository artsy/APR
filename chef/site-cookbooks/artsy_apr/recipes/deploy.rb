deploy_user = "deploy"
deploy_target = "/home/#{deploy_user}/current"
application_name = node[:application_name]
configuration = node["artsy"]["config"][application_name]

### BEGIN DEPLOY

include_recipe "citadel::default"

directory '/home/deploy/releases' do
  user 'deploy'
  group 'deploy'
end

if node['environment'] == "development"
  aws_access_key_id = node['citadel']['access_key_id']
  aws_secret_access_key = node['citadel']['secret_access_key']
else
  aws_access_key_id = nil
  aws_secret_access_key = nil
end

timestamp = ::Time.now.strftime('%Y%m%d%H%M%S%L')

aws_s3_file '/tmp/apr.tgz' do
  bucket 'artsy-deploy'
  remote_path 'apr/latest.tgz'
  aws_access_key_id aws_access_key_id
  aws_secret_access_key aws_secret_access_key
  owner deploy_user
  notifies :create, "directory[/home/deploy/releases/#{timestamp}]", :immediately
  notifies :restart, "supervisor_service[#{application_name}]", :delayed
end

directory "/home/deploy/releases/#{timestamp}" do
  user 'deploy'
  group 'deploy'
  action :nothing
  notifies :run, 'execute[unpack-release]', :immediately
end

execute 'unpack-release' do
  command "tar xvzf /tmp/apr.tgz -C /home/deploy/releases/#{timestamp}"
  action :nothing
  notifies :run, 'execute[chown-release]', :immediately
end

execute 'chown-release' do
  command "chown -R #{deploy_user} /home/deploy/releases/#{timestamp}"
  action :nothing
  notifies :create, "link[#{deploy_target}]", :immediately
end

link deploy_target do
  to "/home/deploy/releases/#{timestamp}"
  action :nothing
end

### END DEPLOY

environment = {
  "USER" => deploy_user,
  "HOME" => "/home/#{deploy_user}",
  "PORT" => "4000"
}

unless configuration["environment"].nil?
  environment.merge! configuration["environment"]
end

command = '/bin/sh ./rel/apr/bin/apr foreground'

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
