require_relative 'xml_processor'

class Underscorize
  class UnderscorizeXmlProcessor < XmlProcessor
    def rename(original_name)
      UnderscorizeRenamer.rename(original_name)
    end
  end

  class UnderscorizeRenamer 
    def self.rename(original_name)
      '_' + original_name.camelize
    end
  end

  def initialize(project_path)
    @project_path = project_path
  end

  def run
    UnderscorizeXmlProcessor.new('/Users/kento/ios/HatalikeSwift/HatalikeSwift/View/SearchByJob/SearchByJobStoryboard.storyboard').run
  end

  private
end

# UnderscorizeProcessor.new('/Users/kento/ios/HatalikeSwift/HatalikeSwift/View/SearchByJob/SearchByJobStoryboard.storyboard').run
Underscorize.new('/Users/kento/ios/HatalikeSwift/HatalikeSwift/').run

