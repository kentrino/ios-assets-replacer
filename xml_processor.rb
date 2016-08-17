require 'nokogiri'
require 'active_support/core_ext/string/inflections'

class XmlProcessor
  def initialize(filepath)
    @filepath = filepath
    @resource_names = list_resource
  end
  
  def run
    replace_on_objects_node
    replace_on_resouce_node
    renamed_resources
  end

  def set_rename(&block)
    define_singleton_method('rename', &block)
  end
  
  private
  def renamed_resources
    @resource_names.map do |resource_name|
      rename(resource_name)
    end
  end

  def list_resource
    doc = Nokogiri::XML(File.read(@filepath))
    doc.css('resources > image').map{ |image|
      image['name']
    }
  end

  def replace_on_resouce_node
    doc = Nokogiri::XML(File.read(@filepath))
    doc.css('resources > image').map{ |image|
      image['name'] = rename(image['name'])
    }
    File.write(@filepath, doc.to_xml(indent: 4, encoding: 'UTF-8'))
  end

  def replace_on_objects_node
    new_file_str = File.read(@filepath).split("\n").each do |line|
      @resource_names.each do |resource_name|
        # image= と backgroundImage= について置き換えを行うがほかがあるかは未調査
        # userLabel="btn_backgorund">が残ったりする
        line.gsub!(/([iI]mage=)"(#{resource_name})"/) { 
          $1 + '"' +  rename(resource_name) + '"'
        }
      end
    end.join("\n") + "\n"
    File.write(@filepath, new_file_str)
  end

  def rename(original_name)
    raise NotImplementedError.new("You must implement #{self.class}##{__method__}")
  end
end
