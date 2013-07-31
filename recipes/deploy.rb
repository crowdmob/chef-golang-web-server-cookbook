
node[:deploy].each do |application, _|
  if node[:deploy][application][:application_type] != 'nutty'
    Chef::Log.debug("Skipping nutty::deploy for application #{application} as it is not set as a nutty app")
    next
  end
  
  nutty_deploy_dir do
    user    node[:deploy][application][:user]
    group   node[:deploy][application][:group]
    path    node[:deploy][application][:deploy_to]
  end

  nutty_scm do
    deploy_data   node[:deploy][application]
    app           application
    go_get?       node[:nutty][application][:auto_go_get_on_deploy]
    go_build?     node[:nutty][application][:auto_go_build_on_deploy]
    gopath        "#{node[:deploy][application][:deploy_to]}/current/build"
  end

  nutty_deploy_config_and_monit do
    application_name            application
    hostname                    node[:hostname]
    basicauth_users             node[:nutty][application][:basicauth_users]
    nutty_application_settings  node[:nutty][application]
    deploy_to                   node[:deploy][application][:deploy_to]
    env_vars                    node[:nutty][application][:env]
    monit_conf_dir              node[:monit][:conf_dir]
    group                       node[:deploy][application][:group]
    user                        node[:deploy][application][:user]
    service_realm               node[:nutty][application][:service_realm]
  end

  ruby_block "restart nutty application #{application}" do
    block do
      Chef::Log.info("restart nutty app server via: #{node[:nutty][application][:restart_server_command]}")
      Chef::Log.info(`#{node[:nutty][application][:restart_server_command]}`)
      $? == 0
    end
  end
end
