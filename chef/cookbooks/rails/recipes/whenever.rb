execute "whenever" do
  user "nobody"
  group "nogroup"
  cwd ::File.join(node[:deploy_to], 'current')
  command "bundle exec whenever --update-crontab '#{node[:id]}'"
  action :run
end
