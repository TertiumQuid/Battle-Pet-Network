require 'yaml'
require 'ostruct'
 
class YAMLOpenStruct < OpenStruct
  def initialize(hash = nil)
    @table = {}
    if hash
      for k, v in hash
        @table[k.to_sym] = v.instance_of?(Hash) ? YAMLOpenStruct.new(v) : v
        new_ostruct_member(k)
      end
    end
  end
end
 
APP_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/application.yml")
AppConfig = YAMLOpenStruct.new(APP_CONFIG)