#
# Cookbook Name:: postgres
# Recipe:: default
#

package "postgresql" do
  action :install
end

node.set_unless[:postgres_password] = "secret"

bash "assign-postgres-password" do
  user 'postgres'
  code <<-EOH
echo "ALTER ROLE postgres ENCRYPTED PASSWORD '#{node[:postgres_password]}';" | psql
  EOH
  action :run
end

execute "create-db" do
  user 'postgres'
  command "createdb #{node[:id]}"
  not_if "sudo -u postgres psql --list | grep #{node[:id]}"
end
