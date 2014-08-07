class ::Hash
    def deep_merge(second)
        merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
        self.merge(second, &merger)
    end
end

Chef::Log.debug('creating json based config')

if node["config"]["global"]["json"]
  Chef::Log.debug('global config found');
  config = node["config"]["global"]["json"]
  config_path = node["config"]["global"]["path"]
else
  config = []
  path = ""
end

node[:deploy].each do |application, deploy|
  if node["config"][application]["json"]
    Chef::Log.debug('merging found app config');
    config_app = node["config"][application]["json"]
    config_app = config.deep_merge(config_app)
  else
    config_app = config
  end

  if node["config"][application]["path"]
    config_path = node["config"][application]["path"]
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