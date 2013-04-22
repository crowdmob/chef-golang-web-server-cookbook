define :nutty_user_and_group do
  # user
  # group
  # home
  # shell
  
  group params[:group]

  user params[:user] do
    action :create
    comment "deploy user"
    uid next_free_uid
    gid params[:group]
    home params[:home]
    supports :manage_home => true
    shell params[:shell]
    not_if do
      existing_usernames = []
      Etc.passwd {|user| existing_usernames << user['name']}
      existing_usernames.include?(params[:user])
    end
  end
end