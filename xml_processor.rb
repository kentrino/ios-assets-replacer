require 'nokogiri'
require 'active_support/core_ext/string/inflections'

class XmlProcessor
  def initialize(filepath)
    @filepath = filepath
    @resource_names = resource_names
    @rename_agenda = {}
    @noop = false
  end
  attr_accessor :rename_agenda

  def run(noop: false)
    @noop = noop

    replace_on_objects_node
    replace_on_resouce_node
  end

  def resource_names
    return @resource_names if @resource_names

    doc = Nokogiri::XML(File.read(@filepath))
    doc.css('resources > image').map do |image|
      image['name']
    end
  end

  private

  def replace_on_resouce_node
    doc = Nokogiri::XML(File.read(@filepath))
    doc.css('resources > image').map do |image|
      image['name'] = rename(image['name'])
    end
    File.write(@filepath, doc.to_xml(indent: 4, encoding: 'UTF-8')) unless @noop
  end

  def replace_on_objects_node
    new_file_str = File.read(@filepath).split("\n").each do |line|
      resource_names.each do |resource_name|
        # image= と backgroundImage= について置き換えを行うがほかがあるかは未調査
        # userLabel="btn_backgorund">が残ったりする
        line.gsub!(/([iI]mage=)"(#{resource_name})"/) do
          Regexp.last_match(1) + '"' + rename(resource_name) + '"'
        end
      end
    end.join("\n") + "\n"
    File.write(@filepath, new_file_str) unless @noop
  end

  def rename(_original_name)
    raise NotImplementedError, "You must implement #{self.class}##{__method__}"
  end
end
