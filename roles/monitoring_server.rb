name 'monitoring_server'
description 'Monitoring server'
run_list *[
  'recipe[munin]',
  'recipe[rsyslog]',
  'recipe[rsyslog::server]',
  'recipe[loganalyzer]'
]
