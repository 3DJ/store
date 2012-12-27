#
# Cookbook Name:: rails
# Recipe:: rails
#
# Copyright 2011, Smashing Boxes
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

rails_env = "production"
node.run_state[:rails_env] = rails_env

## Get this first.
package "build-essential" do
  action :install
end

## Then, install any application specific packages
if node[:packages]
  node[:packages].each do |pkg,ver|
    package pkg do
      action :install
      version ver if ver && ver.length > 0
    end
  end
end

## Next, install any application specific gems
if node[:gems]
  node[:gems].each do |gem,ver|
    gem_package gem do
      action :install
      version ver if ver && ver.length > 0
    end
  end
end

# We need therubyracer for any Rails 3.1 apps
# gem_package "therubyracer" do
#   options("--no-rdoc --no-ri")
#   action :install
# end

# We'll need this to install bundled gems
gem_package "bundler" do
  options("--no-rdoc --no-ri")
  action :install
end

# Make sure we have this too
gem_package "rake" do
  options("--no-rdoc --no-ri")
  action :install
end

# We need to prepare the user 'nobody'
execute "nobody-home" do
  command "usermod --home #{node[:deploy_to]} nobody"
end

directory node[:deploy_to] do
  owner "nobody"
  group "nogroup"
  mode '0755'
  recursive true
end

directory "#{node[:deploy_to]}/shared" do
  owner "nobody"
  group "nogroup"
  mode '0755'
  recursive true
end

%w{ log pids system vendor_bundle }.each do |dir|
  directory "#{node[:deploy_to]}/shared/#{dir}" do
    owner "nobody"
    group "nogroup"
    mode '0755'
    recursive true
  end
end

if node.has_key?("deploy_key")
  ruby_block "write_key" do
    block do
      f = ::File.open("#{node[:deploy_to]}/id_deploy", "w")
      f.print(node[:deploy_key])
      f.close
    end
    not_if do ::File.exists?("#{node[:deploy_to]}/id_deploy"); end
  end

  file "#{node[:deploy_to]}/id_deploy" do
    owner "nobody"
    group "nogroup"
    mode '0600'
  end

  template "#{node[:deploy_to]}/deploy-ssh-wrapper" do
    source "deploy-ssh-wrapper.erb"
    owner "nobody"
    group "nogroup"
    mode "0755"
    variables node.to_hash
  end
end

## Then, deploy
deploy_revision node[:id] do
  revision node[:revision][node.chef_environment]
  repository node[:repository]
  user "nobody"
  group "nogroup"
  deploy_to node[:deploy_to]
  environment 'RAILS_ENV' => rails_env
  action node[:force][node.chef_environment] ? :force_deploy : :deploy
  ssh_wrapper "#{node[:deploy_to]}/deploy-ssh-wrapper" if node[:deploy_key]
  shallow_clone true
  before_migrate do
    user "nobody"
    group "nogroup"
    link "#{release_path}/vendor/bundle" do
      to "#{node[:deploy_to]}/shared/vendor_bundle"
    end
    common_groups = %w{development test cucumber staging}
    execute "bundle install --path #{node[:deploy_to]}/shared/vendor_bundle --deployment --without #{(common_groups -([node.chef_environment])).join(' ')}" do
      user "root"
      group "root"
      ignore_failure true
      cwd release_path
    end
  end
  before_symlink do
    user "nobody"
    group "nogroup"
    execute "cd #{release_path}; RAILS_ENV=#{rails_env} bundle exec rake assets:precompile; RAILS_ENV=#{rails_env} bundle exec rake db:migrate"
  end
end
