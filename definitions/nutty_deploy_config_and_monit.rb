define :nutty_deploy_config_and_monit do
  # application_name
  # nutty_application_settings
  # hostname
  # deploy_to
  # env_vars
  # monit_conf_dir
  # group
  # user

  service 'monit' do
    action :nothing
  end

  template "#{params[:deploy_to]}/shared/config/nutty.properties" do
    source  'nutty.properties.erb'
    mode    '0660'
    owner    params[:user]
    group    params[:group]
    variables(
      :application_name => params[:application_name],
      :deploy_path      => params[:deploy_to],
      :env_vars         => params[:env_vars],
      :service_realm    => params[:service_realm],
      :kafka_partition  => (params[:hostname].match(/(\d+)(?!.*\d)/).nil? ? 0 : params[:hostname].match(/(\d+)(?!.*\d)/)[0].to_i - 1)
    )
  end
  
  template "#{params[:deploy_to]}/current/nutty-#{params[:application_name]}-server-daemon" do
    source   'nutty-server-daemon.erb'
    owner    'root'
    group    'root'
    mode     '0751'
    variables(
      :pid_file         => params[:nutty_application_settings][:pid_file],
      :release_path     => "#{params[:deploy_to]}/current",
      :application_name => params[:application_name],
      :config_file      => params[:nutty_application_settings][:config_file],
      :output_file      => params[:nutty_application_settings][:output_file]
    )
  end
  
  template "#{params[:monit_conf_dir]}/nutty_#{params[:application_name]}_server.monitrc" do
    source  'nutty_server.monitrc.erb'
    owner   'root'
    group   'root'
    mode    '0644'
    variables(
      :application_name => params[:application_name],
      :release_path     => "#{params[:deploy_to]}/current",
      :port             => params[:env_vars]['PORT']
    )
    notifies :restart, resources(:service => 'monit'), :immediately
  end
end
