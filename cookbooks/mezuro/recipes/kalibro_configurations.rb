include_recipe 'mezuro::service'
include_recipe 'mezuro::repo'

package 'kalibro-configurations' do
  action :upgrade
end

template '/etc/mezuro/kalibro-configurations/database.yml' do
  source 'kalibro_configurations/database.yml.erb'
  owner 'kalibro_configurations'
  group 'kalibro_configurations'
  mode '0600'
  notifies :restart, 'service[kalibro-configurations.target]'
end

CONFIGURATIONS_DIR='/usr/share/mezuro/kalibro-configurations'

execute 'kalibro-configurations:schema' do
  command 'RAILS_ENV=production bundle exec rake db:schema:load'
  cwd CONFIGURATIONS_DIR
  user 'kalibro_configurations'
end

execute 'kalibro-configurations:migrate' do
  command 'RAILS_ENV=production bundle exec rake db:migrate'
  cwd CONFIGURATIONS_DIR
  user 'kalibro_configurations'
  notifies :restart, 'service[kalibro-configurations.target]'
end

execute 'kalibro-configurations:open_port' do
  command 'semanage port -a -t http_port_t -p tcp 83'
  user 'root'
  only_if '! semanage port -l | grep "^\(http_port_t\)\(.\)\+\(\s83,\)"'
end

template '/etc/nginx/conf.d/kalibro-configurations.conf' do
  source 'kalibro_configurations/nginx.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[nginx]'
end
