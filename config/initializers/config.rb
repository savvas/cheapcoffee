# Load FB settings

module Facebook
  CONFIG = YAML.load(ERB.new(File.read("#{Rails.root}/config/facebook.yml")).result)[Rails.env]
  APP_ID = CONFIG['app_id']
  SECRET = CONFIG['secret']
end

