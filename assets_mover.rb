require 'fileutils'
require 'json'

class ImagesetCopier

  # @param imageset_path [String] 元のimagesetのフルパス
  # @param distination_relative_path [String] imagesetのフォルダ名も含めた名前。例：HogeController/Fuga
  def initialize(imageset_path, distination_relative_path)
    @imageset_path = imageset_path
    @distination_relative_path = distination_relative_path
    @distination_name = File.basename(@distination_relative_path)
    @distination_path = imageset_path.gsub(/(.+Assets.xcassets\/).+/){ $1 } + @distination_relative_path + '.imageset/'
  end

  def run
    copy_directory
    change_contents
  end

  private
  def copy_directory
    distination_dir = File.dirname(@distination_path) + '/'
    FileUtils.mkdir_p(distination_dir)
    FileUtils.rm_rf(@distination_path)
    FileUtils.cp_r(@imageset_path, @distination_path, remove_destination: true)
  end

  # リネームとContents.jsonの変更を行う
  def change_contents
    contents_json_path = @distination_path + 'Contents.json'
    json_str = File.read(contents_json_path)
    data = JSON.parse(json_str, symbolize_names: true)
    data[:images].each.with_index{ |image, i|
      if image[:filename] == nil
        next
      end
      
      if image[:scale] == '1x' 
        new_file_name = @distination_name + File.extname(image[:filename])
      else
        new_file_name = @distination_name + '@' + image[:scale] + File.extname(image[:filename])
      end
      File.rename(@distination_path + image[:filename], @distination_path + new_file_name)
      data[:images][i][:filename] = new_file_name
    }

    File.write(contents_json_path, data.to_json(
      :indent    => ' ' * 2,
      :object_nl => "\n",
      :array_nl => "\n",
      :space     => ' '
    ))
  end
end

ImagesetCopier.new('/Users/kento/ios/HatalikeSwift/HatalikeSwift/Assets.xcassets/Detail/BtnDetail4Apply.imageset', 'Hoge/Fuga').run

