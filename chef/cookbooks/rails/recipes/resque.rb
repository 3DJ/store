include_recipe "bluepill"

bluepill_monitor node[:id] do
  source "bluepill_workers.conf.erb"
  worker_count 1
  log_path "/var/log/bluepill_stdout.log"
  working_dir node[:deploy_to]+"/current"
  interval 1
  user "root"
  group "root"
  memory_limit 250 # megabytes
  cpu_limit 50 # percent
  queues ['*']
end
