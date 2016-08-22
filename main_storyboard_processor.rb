require 'yaml'
require_relative 'prefix_store'

class MainStoryboardProcessor
  def initialize(filepath)
    @filepath = filepath
    @rename_agendas = []
    @noop = false
  end
  attr_accessor :rename_agendas

  def run(noop: false)
    @noop = noop
    replace_scenes
    replace_resources
  end

  private

  def replace_scenes
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

        image_elements = node.css('[image]')
        image_elements += node.css('[backgroundImage]')

        image_elements.each do |image_element|
          original_name = image_element[:image] || image_element[:backgroundImage]
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

          image_element[original_name] = new_resource_name

          @rename_agendas.push({ original_name => new_resource_name_with_path })
        end
      end
    end

    File.write(@filepath, doc.to_xml) unless @noop
  end

  def replace_resources
    doc = Nokogiri::XML(File.read(@filepath))

    images = {}
    resources = doc.css('resources')
    if resources.empty?
      # リソースが一つもない場合クラッシュするのを防ぐ
      return
    end

    resources.children.each do |image|
      # 改行だけのノードを無視
      if image[:name].nil?
        image.remove
        next
      end
      images[image[:name]] = {name: image[:name], width: image[:width], height: image[:height]}
      image.remove
    end

    # imagesを再構築
    resources[0].add_child("\n")

    @rename_agendas.each do |rename_agenda|
      rename_agenda.each do |original_name, new_name_with_path|
        image = Nokogiri::XML::Node.new 'image', doc
        image[:name] = File.basename(new_name_with_path)

        # 整合のとれていないStoryboardの場合クラッシュする
        image[:width] = images[original_name][:width]
        image[:height] = images[original_name][:height]
        resources[0].add_child('      ')
        resources[0].add_child(image)
        resources[0].add_child("\n")
      end
    end

    resources[0].add_child('    ')

    File.write(@filepath, doc) unless @noop
  end
end