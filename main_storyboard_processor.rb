require 'yaml'
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

class MainStoryboardProcessor
  def initialize(filepath)
    @filepath = filepath
    @rename_agendas = []
    @noop = false
  end
  attr_accessor :rename_agenda

  def run(noop: false)
    @noop = noop
    # return unless @filepath.include?('Screen')
    replace_on_scene
  end

  private

  def replace_on_scene
    doc = Nokogiri::XML(File.read(@filepath))
    doc.css('objects').each do |object|
      # nodeにはviewController等が入る予定
      object.children.each do |node|
        id = node[:id]
        # 空要素を弾く
        next if id.nil?

        prefix = if node[:customClass].nil?
                   # 手入力
                   ''
                 else
                   node[:customClass].gsub('ViewController', '')
                 end

        node.to_xml.split("\n").each do |line|
          next unless match = /([iI]mage=)"([^"]+)"/.match(line)
          original_name = match[2]
          if prefix.empty?
            prefix = if PrefixStore.instance[id]
                       PrefixStore.instance[id]
                     else
                       print("#{original_name} in #{File.basename(@filepath)}:")
                       input = gets.chomp
                       PrefixStore.instance[id] = input
                     end
          end
          new_resource_name = prefix + MainRenamer.remove_underscore(original_name)
          new_resource_name_with_path = prefix + '/' + new_resource_name
          print("#{original_name} -> #{new_resource_name_with_path}\n")

          @rename_agendas = {original_name: original_name, new_path: new_resource_name_with_path}
        end
      end
    end
    p @rename_agendas
  end
end