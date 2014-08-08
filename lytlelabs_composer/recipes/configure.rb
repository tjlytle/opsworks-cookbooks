if node[:composer] && node[:composer][:oauth_key]
  deploy_user = node[:composer][:user]
  deploy_group = node[:composer][:group]

  if node[:composer][:home]
    home_dir = node[:composer][:home]
  else
    home_dir = "/home/#{deploy_user}"
  end

  Chef::Log.debug("Creating #{home_dir}/.composer")
  directory "#{home_dir}/.composer" do
    owner     deploy_user
    group     deploy_group
    mode      "0750"
    recursive true
  end

  Chef::Log.debug("Creating #{home_dir}/.composer/config.json")
  template "#{home_dir}/.composer/config.json" do
    owner  deploy_user
    group  deploy_group
    source "composer.config.json.erb"
    mode   "0640"
    variables(
      :oauth_key => node["composer"]["oauth_key"]
    )
  end

else
  Chef::Log.error('Configuration error, missing node["composer"]["oauth_key"]')
end