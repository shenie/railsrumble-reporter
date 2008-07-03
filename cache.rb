
# 
# A file-based cache using yaml format
# 
require 'yaml'

class Cache
  def initializer(file)
    @file = file
    @cache = File.exist?(cache_file) ? YAML.load_file(cache_file) : {}
  end
  
  def keep(message)
    unless @cache[:last_message] == message
      File.open @cache_file, 'w' do |f|
        f.write({:last_message => message}.to_yaml)
      end
      message
    end
  end
end
