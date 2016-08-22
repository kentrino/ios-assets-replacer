require 'singleton'

class PrefixStore
  include Singleton
  FILE = '.prefix_store'

  def initialize
    unless File.exist?(FILE)
      @data = {}
      return
    end

    file = File.read(FILE)
    @data = YAML.load(file)
  end

  def [](accessor)
    @data[accessor]
  end

  def []=(accessor, value)
    @data[accessor] = value
    File.write(FILE, @data.to_yaml)
    @data = YAML.load(File.read(FILE))
  end
end
