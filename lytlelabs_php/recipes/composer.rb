Chef::Log.debug('running composer where config file is found');
node[:deploy].each do |application, deploy|

  if !::File.exists?("#{deploy[:deploy_to]}/current/composer.json")
    Chef::Log.info("no composer.json found in #{deploy[:deploy_to]}/current")
  else
    Chef::Log.debug("running composer install")
    php_composer "#{deploy[:deploy_to]}/current" do
      action [:setup, :install]
    end   
  end
end
