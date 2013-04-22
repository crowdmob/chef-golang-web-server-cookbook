node[:deploy].each do |application, _|
  if node[:deploy][application][:application_type] != 'nutty'
    Chef::Log.debug("Skipping nutty::stop for application #{application} as it is not set as a nutty app")
    next
  end

  ruby_block "stop nutty application #{application}" do
    block do
      Chef::Log.info("stop nutty via: #{node[:nutty][application][:stop_server_command]}")
      Chef::Log.info(`#{node[:nutty][application][:stop_server_command]}`)
      $? == 0
    end
  end

end
