# ~FC015
#
# Cookbook Name:: cq
# Definition:: instance
#
# Copyright (C) 2014 Jakub Wadolowski
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

define :cq_instance,
       :id => nil do
  # Helpers
  # ---------------------------------------------------------------------------
  local_id = params[:id]
  instance_home = cq_instance_home(node['cq']['home_dir'], local_id)
  instance_conf_dir = cq_instance_conf_dir(node['cq']['home_dir'], local_id)
  jar_name = cq_jarfile(node['cq']['jar']['url'])
  daemon_name = cq_daemon_name(local_id)

  Chef::Log.warn "Attribute node['cq']['#{params[:id]}']['mode'] is now "\
    "deprecated and can be safely removed." if node['cq'][local_id]['mode']

  # Create CQ instance directory
  # ---------------------------------------------------------------------------
  directory instance_home do
    owner node['cq']['user']
    group node['cq']['group']
    mode '0755'
    action :create
  end

  # Download and unpack CQ JAR file
  # ---------------------------------------------------------------------------
  # Download JAR file to Chef's cache
  remote_file "#{Chef::Config[:file_cache_path]}/#{jar_name}" do
    owner 'root'
    group 'root'
    mode '0644'
    source node['cq']['jar']['url']
    checksum node['cq']['jar']['checksum'] if node['cq']['jar']['checksum']
  end

  # Move JAR file to instance home
  remote_file "#{instance_home}/#{jar_name}" do
    owner node['cq']['user']
    group node['cq']['group']
    mode '0644'
    source "file://#{Chef::Config[:file_cache_path]}/#{jar_name}"
    checksum node['cq']['jar']['checksum'] if node['cq']['jar']['checksum']
  end

  # Unpack CQ JAR file once downloaded
  bash 'Unpack CQ JAR file' do
    user node['cq']['user']
    group node['cq']['group']
    cwd instance_home
    code "java -jar #{jar_name} -unpack"
    action :run

    # Do not unpack if crx-quickstart exists inside CQ instance home
    not_if { ::Dir.exist?("#{instance_home}/crx-quickstart") }
  end

  # Deploy CQ license file
  # ---------------------------------------------------------------------------
  # Download license file to Chef's cache
  remote_file "#{Chef::Config[:file_cache_path]}/license.properties" do
    owner 'root'
    group 'root'
    mode '0644'
    source node['cq']['license']['url']
    checksum node['cq']['license']['checksum'] if
      node['cq']['license']['checksum']
  end

  # Move license to instance home
  remote_file "#{instance_home}/license.properties" do
    owner node['cq']['user']
    group node['cq']['group']
    mode '0644'
    source "file://#{Chef::Config[:file_cache_path]}/license.properties"
    checksum node['cq']['license']['checksum'] if
      node['cq']['license']['checksum']
  end

  # Create init script
  # ---------------------------------------------------------------------------
  template "/etc/init.d/#{daemon_name}" do
    owner 'root'
    group 'root'
    mode '0755'
    source 'cq.init.erb'
    variables(
      :daemon_name => daemon_name,
      :full_name => "Adobe CQ #{node['cq']['version']}"\
                    " #{local_id.to_s.capitalize}",
      :conf_file => "#{cq_instance_conf_dir(node['cq']['home_dir'],
                                            local_id)}/"\
                                            "#{daemon_name}.conf"
    )
  end

  # Render CQ config file
  # ---------------------------------------------------------------------------
  template "#{instance_conf_dir}/cq#{cq_version('short_squeezed')}"\
           "-#{local_id}.conf" do
    owner node['cq']['user']
    group node['cq']['group']
    mode '0644'
    source 'cq.conf.erb'
    variables(
      :port => node['cq'][local_id]['port'],
      :jmx_port => node['cq'][local_id]['jmx_port'],
      :debug_port => node['cq'][local_id]['debug_port'],
      :instance_home => instance_home,
      :run_mode => node['cq'][local_id]['run_mode'],
      :min_heap => node['cq'][local_id]['jvm']['min_heap'],
      :max_heap => node['cq'][local_id]['jvm']['max_heap'],
      :max_perm_size => node['cq'][local_id]['jvm']['max_perm_size'],
      :code_cache => node['cq'][local_id]['jvm']['code_cache_size'],
      :jvm_general_opts => node['cq'][local_id]['jvm']['general_opts'],
      :jvm_code_cache_opts => node['cq'][local_id]['jvm']['code_cache_opts'],
      :jvm_gc_opts => node['cq'][local_id]['jvm']['gc_opts'],
      :jvm_jmx_opts => node['cq'][local_id]['jvm']['jmx_opts'],
      :jvm_debug_opts => node['cq'][local_id]['jvm']['debug_opts'],
      :jvm_extra_opts => node['cq'][local_id]['jvm']['extra_opts']
    )

    notifies :restart,
             "service[cq#{cq_version('short_squeezed')}-#{local_id}]",
             :immediately
  end

  # Enable & start CQ instance
  # ---------------------------------------------------------------------------
  service "#{daemon_name} (enable)" do
    service_name daemon_name
    action :enable
  end

  service daemon_name do
    supports :status => true, :restart => true
    action :start

    notifies :run, "ruby_block[cq-#{local_id}-start-guard]", :immediately
  end

  # Wait until CQ is fully up and running
  # ---------------------------------------------------------------------------
  ruby_block "cq-#{local_id}-start-guard" do # ~FC014
    block do
      require 'net/http'
      require 'uri'

      # Pick valid resource to verify CQ instance full start
      uri = URI.parse("http://localhost:#{node['cq'][local_id]['port']}" +
                      node['cq']['healthcheck_resource'])

      # Start timeout
      timeout = node['cq']['start_timeout']

      response = '-1'
      start_time = Time.now

      # Keep asking CQ instance for login page HTTP status code until it
      # returns 200 or specified time has elapsed
      while response != '200'
        begin
          response = Net::HTTP.get_response(uri).code
        rescue => e
          Chef::Log.debug("Error occurred while trying to send GET #{uri} "\
                          "request: #{e}")
        end
        sleep(5)
        time_diff = Time.now - start_time
        abort "Aborting since #{daemon_name} "\
              'start took more than '\
              "#{timeout / 60} minutes " if time_diff > timeout
      end

      Chef::Log.info("CQ start time: #{time_diff} seconds")
    end

    action :nothing
  end
end
