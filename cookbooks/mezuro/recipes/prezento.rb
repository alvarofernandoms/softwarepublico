include_recipe 'mezuro::service'
include_recipe 'mezuro::repo'

package 'prezento-spb' do
  action :upgrade
end

template '/etc/mezuro/prezento/database.yml' do
  source 'prezento/database.yml.erb'
  owner 'prezento'
  group 'prezento'
  mode '0600'
  notifies :restart, 'service[prezento.target]'
end

PREZENTO_DIR='/usr/share/mezuro/prezento'

execute 'prezento:schema' do
  command 'RAILS_ENV=production bundle exec rake db:schema:load'
  cwd PREZENTO_DIR
  user 'prezento'
end

execute 'prezento:migrate' do
  command 'RAILS_ENV=production bundle exec rake db:migrate'
  cwd PREZENTO_DIR
  user 'prezento'
  notifies :restart, 'service[prezento.target]'
end

template PREZENTO_DIR + '/config/kalibro.yml' do
  source 'prezento/kalibro.yml.erb'
  owner 'prezento'
  group 'prezento'
  mode '0644'
  notifies :restart, 'service[prezento.target]'
end

execute 'prezento:open_port' do
  command 'semanage port -a -t http_port_t -p tcp 84'
  user 'root'
  only_if '! semanage port -l | grep "^\(http_port_t\)\(.\)\+\(\s84,\)"'
end

template '/etc/nginx/conf.d/prezento.conf' do
  source 'prezento/nginx.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
  notifies :restart, 'service[nginx]'
end

