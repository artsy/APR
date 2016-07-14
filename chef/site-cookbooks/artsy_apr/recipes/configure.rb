deploy_user = "deploy"

directory "/home/#{deploy_user}/.ssh" do
  owner deploy_user
  recursive true
end
