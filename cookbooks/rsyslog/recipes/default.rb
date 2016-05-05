package 'rsyslog' do
  action [:install, :upgrade]
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

