include_recipe 'golang'

node[:deploy].each do |application, _|
  if node[:deploy][application][:application_type] != 'nutty'
    Chef::Log.debug("Skipping nutty::deploy for application #{application} as it is not set as a nutty app")
    next
  end
  
  nutty_user_and_group do
    user    node[:deploy][application][:user]
    group   node[:deploy][application][:group]
    home    node[:deploy][application][:home]
    shell   node[:deploy][application][:shell]
  end
  
  nutty_deploy_dir do
    user    node[:deploy][application][:user]
    group   node[:deploy][application][:group]
    path    node[:deploy][application][:deploy_to]
  end
  
end
