require 'nokogiri'

class Main
  def run
  end

  private
  def get_image_resource_names_in_storyboard(storyboard_file)
    doc = Nokogiri::XML(File.read(storyboard_file))
    p doc.css('viewController').size
  end

  def 
end


Main.new.process_storyboard('/Users/kento/ios/HatalikeSwift/HatalikeSwift/View/SearchByJob/SearchByJobStoryboard.storyboard')


