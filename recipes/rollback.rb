node[:deploy].each do |application, _|
  if node[:deploy][application][:application_type] != 'nutty'
    Chef::Log.debug("Skipping nutty::rollback for application #{application} as it is not set as a nutty app")
    next
  end

  deploy node[:deploy][application][:deploy_to] do
    user node[:deploy][application][:user]
    action 'rollback'
    restart_command "sleep #{node[:deploy][application][:sleep_before_restart]} && #{node[:nutty][application][:restart_server_command]}"

    only_if do
      File.exists?(node[:deploy][application][:current_path])
    end
  end

  ruby_block "restart nutty application #{application}" do
    block do
      Chef::Log.info("restart nutty application via: #{node[:nutty][application][:restart_server_command]}")
      Chef::Log.info(`#{node[:nutty][application][:restart_server_command]}`)
      $? == 0
    end
  end

end
