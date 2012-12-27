include_recipe "postgres"

# create new database.yml
directory "#{node[:deploy_to]}/shared/config" do
  owner "nobody"
  group "nogroup"
  mode '0755'
  recursive true
end

template "#{node[:deploy_to]}/shared/config/database.yml" do
  source 'database.yml.erb'
  owner "nobody"
  group "nogroup"
  mode 0644
  variables({
              :environment => node.chef_environment,
              :adapter => 'postgresql',
              :database => node[:id],
              :username => 'postgres',
              :password => node[:postgres_password],
              :host => '127.0.0.1',
              :pool => '5'
            })
end
