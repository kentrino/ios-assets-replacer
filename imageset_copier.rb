require 'fileutils'
require 'json'

class ImagesetCopier
  # @param imageset_path [String] 元のimagesetのフルパス
  # @param distination_name_with_path [String] imagesetのフォルダ名も含めた名前。例：HogeController/Fuga
  def initialize(imageset_path, distination_name_with_path)
    @imageset_path = imageset_path
    @distination_name = File.basename(distination_name_with_path)
    @distination_path = imageset_path.gsub(%r{(.+Assets.xcassets\/).+}) { Regexp.last_match(1) } + distination_name_with_path + '.imageset/'
  end

  def self.default_distination_path_from_resource_name(imageset_path, destination_resource_name)
    # まよう
    # imageset_path = ProjectUtils.imageset_path_from_resource_name(source_resource_name)
    (File.dirname(imageset_path.gsub(%r{.+Assets.xcassets\/(.+)}) { Regexp.last_match(1) }) + '/').gsub(%r{^\.\/}, '') + destination_resource_name
  end

  def copy(noop: false)
    return if noop

    copy_directory
    change_contents
  end

  def move(noop: false)
    return if noop

    copy_directory
    change_contents
    FileUtils.rm_rf(@imageset_path)
  end

  private

  def copy_directory
    distination_dir = File.dirname(@distination_path) + '/'
    FileUtils.mkdir_p(distination_dir)
    FileUtils.rm_rf(@distination_path)
    @imageset_path
    @distination_path
    FileUtils.cp_r(@imageset_path, @distination_path, remove_destination: true)
  end

  # リネームとContents.jsonの変更を行う
  def change_contents
    contents_json_path = @distination_path + 'Contents.json'
    json_str = File.read(contents_json_path)
    data = JSON.parse(json_str, symbolize_names: true)
    data[:images].each.with_index do |image, i|
      next if image[:filename].nil?

      new_file_name = if image[:scale] == '1x'
                        @distination_name + File.extname(image[:filename])
                      else
                        @distination_name + '@' + image[:scale] + File.extname(image[:filename])
                      end

      File.rename(@distination_path + image[:filename], @distination_path + new_file_name)
      data[:images][i][:filename] = new_file_name
    end

    File.write(contents_json_path, data.to_json(
                                     indent: ' ' * 2,
                                     object_nl: "\n",
                                     array_nl: "\n",
                                     space: ' '
    ))
  end
end

# ImagesetCopier.new('/Users/kento/ios/HatalikeSwift/HatalikeSwift/Assets.xcassets/Detail/BtnDetail4Apply.imageset', 'Hoge/Fuga').run
