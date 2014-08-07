class ::Hash
    def deep_merge(second)
        merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
        self.merge(second, &merger)
    end
end

Chef::Log.debug('creating json based config')

if node["config"]["json"]
  Chef::Log.debug('global config found');
  config = node["config"]["json"]
  config_path = node["config"]["path"]
else
  config = []
end

node[:deploy].each do |application, deploy|

  if deploy["config"]["json"]
    Chef::Log.debug('merging found app config');
    config_app = deploy["config"]["json"];
    config_app = config.deep_merge(config_app)
  else
    config_app = config
  end

  if deploy["config"]["path"]
    config_path = deploy["config"]["path"]
  end

  Chef::Log.debug(config_app);

  file "#{deploy[:deploy_to]}/current/#{config_path}/config.json" do
    owner deploy[:user]
    group deploy[:group]
    mode "0666"
    content config_app.to_json

    action :create

    only_if do
      ::File.directory?("#{deploy[:deploy_to]}/current/#{config_path}")
    end
  end
end