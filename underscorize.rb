require_relative 'xml_processor'
require_relative 'imageset_copier'
require_relative 'project_utils'
require_relative 'rswift_processor'

class Underscorize
  PROJECT_PATH = '/Users/kento/ios/HatalikeSwift/HatalikeSwift/'.freeze
  NOOP = false

  class UnderscorizeRenamer
    def self.rename(original_name)
      '_' + original_name.camelize
    end
  end

  class UnderscorizeXmlProcessor < XmlProcessor
    def rename(original_name)
      new_name = UnderscorizeRenamer.rename(original_name)
      source_imageset_path = ProjectUtils.imageset_path_from_resource_name(PROJECT_PATH, original_name)
      distination_resource_name_with_path = ImagesetCopier.default_distination_path_from_resource_name(source_imageset_path, new_name)

      @rename_agenda[original_name] = distination_resource_name_with_path

      new_name
    end
  end

  class UnderscorizeRswiftProcessor < RswiftProcessor
    private

    def rename(original_name)
      original_name = get_upper_from_lower_camel(original_name)
      new_name = UnderscorizeRenamer.rename(original_name)
      source_imageset_path = ProjectUtils.imageset_path_from_resource_name(PROJECT_PATH, original_name)
      distination_resource_name_with_path = ImagesetCopier.default_distination_path_from_resource_name(source_imageset_path, new_name)

      @rename_agenda[original_name] = distination_resource_name_with_path

      new_name
    end

    def get_upper_from_lower_camel(str)
      # When str is Camel Case
      if str =~ /[A-Z]/
        str[0] = str[0].upcase
        return str
      end
      str
    end
  end

  def run
    rename_agenda = {}

    ProjectUtils.list_all_storyboard(PROJECT_PATH).each do |storyboard_path|
      xml_processor = UnderscorizeXmlProcessor.new(storyboard_path)
      xml_processor.run(noop: NOOP)
      rename_agenda.merge!(xml_processor.rename_agenda)
    end

    ProjectUtils.list_all_xib(PROJECT_PATH).each do |xib_path|
      xml_processor = UnderscorizeXmlProcessor.new(xib_path)
      xml_processor.run(noop: NOOP)
      rename_agenda.merge!(xml_processor.rename_agenda)
    end

    ProjectUtils.list_all_swift(PROJECT_PATH).each do |swift_path|
      rswift_processor = UnderscorizeRswiftProcessor.new(swift_path)
      rswift_processor.run(noop: NOOP)
      rename_agenda.merge!(rswift_processor.rename_agenda)
    end

    rename_agenda.each do |original_name, new_name_with_path|
      source_imageset_path = ProjectUtils.imageset_path_from_resource_name(PROJECT_PATH, original_name)
      imageset_copier = ImagesetCopier.new(source_imageset_path, new_name_with_path)
      imageset_copier.move(noop: NOOP)
    end
  end
end

Underscorize.new.run
