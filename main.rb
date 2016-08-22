require_relative 'xml_processor'
require_relative 'imageset_copier'
require_relative 'project_utils'
require_relative 'rswift_processor'
require_relative 'main_storyboard_processor'

class MainRenamer
  PROJECT_PATH = '/Users/kento/ios/HatalikeSwift/HatalikeSwift/'.freeze
  NOOP = false

  def self.remove_underscore(original_name)
    new_name = original_name
    if original_name[0] == '_'
      new_name = original_name[1..(original_name.size - 1)]
    end
    new_name
  end

  class MainXibProcessor < XmlProcessor
    private

    def rename(original_name)
      new_resource_name = prefix + MainRenamer.remove_underscore(original_name)
      new_resource_name_with_path = prefix + '/' + new_resource_name

      @rename_agenda[original_name] = new_resource_name_with_path

      new_resource_name
    end

    def prefix
      # ファイルネームからプレフィックスを取得
      File.basename(@filepath, '.*')
    end
  end

  class MainRswiftProcessor < RswiftProcessor
    private

    def rename(original_name)
      new_resource_name = prefix + MainRenamer.remove_underscore(original_name)

      new_resource_name_with_path = prefix + '/' + new_resource_name

      @rename_agenda[original_name] = new_resource_name_with_path

      new_resource_name[0].downcase + new_resource_name[1..(new_resource_name.size - 1)]
    end

    def prefix
      filename = File.basename(@filepath, '.*')

      # ファイル名のサフィックスがViewControllerであれば
      filename.gsub!(/ViewController/, '') if /ViewController/ =~ filename
      filename
    end
  end

  def run
    rename_agendas = []

    ProjectUtils.list_all_storyboard(PROJECT_PATH).each do |storyboard_path|
      storyboard_processor = MainStoryboardProcessor.new(storyboard_path)
      storyboard_processor.run(noop: NOOP)
      rename_agendas.push(storyboard_processor.rename_agenda)
    end

    ProjectUtils.list_all_xib(PROJECT_PATH).each do |xib_path|
      xib_processor = MainXibProcessor.new(xib_path)
      #xib_processor.run(noop: NOOP)
      rename_agendas.push(xib_processor.rename_agenda)
    end

    ProjectUtils.list_all_swift(PROJECT_PATH).each do |swift_path|
      rswift_processor = MainRswiftProcessor.new(swift_path)
      #rswift_processor.run(noop: NOOP)
      rename_agendas.push(rswift_processor.rename_agenda)
    end

    #rename_agendas.each do |rename_agenda|
    #  rename_agenda.each do |original_name, new_name_with_path|
    #    source_imageset_path = ProjectUtils.imageset_path_from_resource_name(PROJECT_PATH, original_name)
    #    imageset_copier = ImagesetCopier.new(source_imageset_path, new_name_with_path)
    #    imageset_copier.copy(noop: NOOP)
    #  end
    #end
  end
end

MainRenamer.new.run
