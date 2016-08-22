require_relative 'xml_processor'
require_relative 'imageset_copier'
require_relative 'project_utils'
require_relative 'rswift_processor'

class Main
  PROJECT_PATH = '/Users/kento/ios/HatalikeSwift/HatalikeSwift/'
  NOOP = false

  class MainRenamer
    def self.remove_underscore(original_name)
      new_name = original_name
      if original_name[0] = '_'
        new_name = original_name[1..(original_name.size - 1)]
      end
      return new_name
    end
  end

  class MainXibProcessor < XmlProcessor
    private
    def rename(original_name)
      new_resource_name = prefix + MainRenamer.remove_underscore(original_name)
      new_resource_name_with_path = prefix + "/" + new_resource_name
     
      @rename_agenda[original_name] = new_resource_name_with_path

      new_resource_name
    end

    def prefix
    # ファイルネームからプレフィックスを取得
      xib_name = File.basename(@filepath, ".*")
    end
  end

  class MainStoryboardProcessor < XmlProcessor
    private
    def rename(original_name)
      #prefixes.each do |prefix, _|
        prf = prefix(original_name)
        if prf.empty?
          new_resource_name = MainRenamer.remove_underscore(original_name)
          new_resource_name_with_path = new_resource_name
          @rename_agenda[original_name] = new_resource_name_with_path
          print("#{original_name} -> #{new_resource_name_with_path}\n")
          return new_resource_name
        end

        new_resource_name = prf + MainRenamer.remove_underscore(original_name)
        new_resource_name_with_path = prf + "/" + new_resource_name
        print("#{original_name} -> #{new_resource_name_with_path}\n")
          
        @rename_agenda[original_name] = new_resource_name_with_path

        new_resource_name
      #end
    end

    def prefix(original_name)
      doc = Nokogiri::XML(File.read(@filepath))
      controller_name = ""
      # better
      # controller_names = {}
      doc.css('viewController').each do |view_controller|
        view_controller.to_xml.split("\n").each do |line|
          if line.match(/([iI]mage=)"(#{original_name})"/)
            if controller_name.empty?
              controller_name = view_controller['customClass'].gsub(/ViewController/, '')
            else
              #print(view_controller['customClass'])
              #print("########## Fatal Error.\n")
            end
          end
        end
      end

      doc.css('view').each do |view|
        view.to_xml.split("\n").each do |line|
          if line.match(/([iI]mage=)"(#{original_name})"/)
            if controller_name.empty?
              controller_name = 'KeepListSubView'
            else
              #print("########## Fatal Error.\n")
            end
          end
        end
      end

      doc.css('navigationController').each do |navigation_controller|
        navigation_controller.to_xml.split("\n").each do |line|
          if line.match(/([iI]mage=)"(#{original_name})"/)
            if controller_name.empty?
              controller_name = navigation_controller['customClass'] || ""
              controller_name = controller_name.gsub(/ViewController/, '')
            else
              # print(navigation_controller['customClass'])
              # print("########## Fatal Error.\n")
            end
          end
        end
      end

      controller_name
    end
  end

  class MainRswiftProcessor < RswiftProcessor
    private
    def rename(original_name)
      new_resource_name = prefix + MainRenamer.remove_underscore(original_name)

      new_resource_name_with_path = prefix + "/" + new_resource_name
     
      @rename_agenda[original_name] = new_resource_name_with_path

      new_resource_name_called_from_r = new_resource_name[0].downcase + new_resource_name[1..(new_resource_name.size - 1)]
    end

    def prefix
      filename = File.basename(@filepath, ".*")

      # ファイル名のサフィックスがViewControllerであれば
      if filename.match('ViewController')
        filename.gsub!(/ViewController/, '')
      end
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
      xib_processor.run(noop: NOOP)
      rename_agendas.push(xib_processor.rename_agenda)
    end

    ProjectUtils.list_all_swift(PROJECT_PATH).each do |swift_path|
      rswift_processor = MainRswiftProcessor.new(swift_path)
      rswift_processor.run(noop: NOOP)
      rename_agendas.push(rswift_processor.rename_agenda)
    end
    
    p rename_agendas

    rename_agendas.each do |rename_agenda|
      rename_agenda.each do |original_name, new_name_with_path|
        source_imageset_path = ProjectUtils.imageset_path_from_resource_name(PROJECT_PATH, original_name)
        imageset_copier = ImagesetCopier.new(source_imageset_path, new_name_with_path)
        imageset_copier.copy(noop: NOOP)
      end
    end

  end
end

Main.new.run
