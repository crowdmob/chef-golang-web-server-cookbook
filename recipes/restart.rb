include_recipe 'nutty::deploy'

node[:deploy].each do |application, _|
  if node[:deploy][application][:application_type] != 'nutty'
    Chef::Log.debug("Skipping deploy::nutty_restart for application #{application} as it is not set as a nutty app")
    next
  end
  
  ruby_block "restart nutty application #{application}" do
    block do
      Chef::Log.info("restart nutty application #{application} via: #{node[:nutty][application][:restart_server_command]}")
      Chef::Log.info(`#{node[:nutty][application][:restart_server_command]}`)
      $? == 0
    end
  end

end
