include_recipe 'nutty::deploy'

node[:deploy].each do |application, _|
  if node[:deploy][application][:application_type] != 'nutty'
    Chef::Log.debug("Skipping nutty::undeploy for application #{application} as it is not set as a nutty app")
    next
  end

  ruby_block "stop nutty application #{application}" do
    block do
      Chef::Log.info("stop nutty application via: #{node[:nutty][application][:stop_server_command]}")
      Chef::Log.info(`#{node[:nutty][application][:stop_server_command]}`)
      $? == 0
    end
  end

  file "#{node[:monit][:conf_dir]}/nutty_#{application}_server.monitrc" do
    action :delete
    only_if do
      ::File.exists?("#{node[:monit][:conf_dir]}/nutty_#{application}_server.monitrc")
    end
  end

  directory "#{node[:deploy][application][:deploy_to]}" do
    recursive true
    action :delete

    only_if do
      ::File.exists?("#{node[:deploy][application][:deploy_to]}")
    end
  end
end
