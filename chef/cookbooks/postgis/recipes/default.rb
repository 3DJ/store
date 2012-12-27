#
# Cookbook Name:: postgis
# Recipe:: default
#

package "postgis" do
  action :install
end

package "postgresql-9.1-postgis" do
  action :install
end

bash "update-db-with-postgis" do
  user 'postgres'
  code <<-EOH
psql -d #{node[:id]} -f /usr/share/postgresql/9.1/contrib/postgis-1.5/postgis.sql
psql -d #{node[:id]} -f /usr/share/postgresql/9.1/contrib/postgis-1.5/spatial_ref_sys.sql
  EOH
  action :run
end

execute "create-db" do
  user 'postgres'
  command "createdb #{node[:id]}"
  not_if "sudo -u postgres psql --list | grep #{node[:id]}"
end
