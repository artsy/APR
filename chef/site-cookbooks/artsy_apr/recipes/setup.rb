include_recipe "artsy_base::default"

include_recipe "#{cookbook_name}::elixir"

include_recipe "nodejs::npm"

apt_repository 'nginx' do
  uri          'ppa:nginx/stable'
  distribution node['lsb']['codename']
end

include_recipe 'ohai'
include_recipe 'nginx::default'

# configure nginx
template "/etc/nginx/sites-available/apr-backend" do
  mode "0644"
end

# enable nginix site config
nginx_site "apr-backend"
