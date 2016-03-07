package 'rsyslog-mysql' do
  action [:install, :upgrade]
end

package 'mariadb-server' do
  action [:install, :upgrade]
end

package 'rsyslog' do
  action [:install, :upgrade]
end

service 'mariadb' do
  action [:enable, :start]
end

cookbook_file '/tmp/mysql-createDB.sql' do
  group 'root'
  owner 'root'
  mode  '644'
end

execute 'createdb:rsyslog' do
  command 'mysql -u root --password= < /tmp/mysql-createDB.sql'
  user 'root'
end

cookbook_file '/tmp/rsyslog-createUser.sql' do
  group 'root'
  owner 'root'
  mode  '644'
end

execute 'createuser:rsyslog' do
  command 'mysql -u root --password= Syslog < /tmp/rsyslog-createUser.sql'
  user 'root'
end

SPB_LOG='/var/log/spb.log'

file SPB_LOG do
  owner 'root'
  group 'root'
  mode 0644
end

template "/etc/rsyslog.d/spb_log.conf" do
  owner 'root'
  group 'root'
  mode 0644
  notifies :restart, 'service[rsyslog]'
end

service 'rsyslog' do
  action [:enable, :restart]
end

execute 'allowing-spb-log' do
  command 'semanage fcontext -a -t httpd_sys_rw_content_t '+SPB_LOG
  user 'root'
end

execute 'enable-spb-log' do
  command 'restorecon -v '+SPB_LOG
  user 'root'
end
