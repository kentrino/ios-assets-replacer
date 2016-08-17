class ProjectUtils
  # project_path must end with /
  def self.list_all_xib(project_path)
    Dir.glob(project_path + '**/*').select do |path|
      File.extname(path) == '.xib'
    end
  end

  def self.list_all_storyboard(project_path)
    Dir.glob(project_path + '**/*').select do |path|
      File.extname(path) == '.storyboard'
    end
  end

  def self.list_all_swift(project_path)
    Dir.glob(project_path + '**/*').select do |path|
      File.extname(path) == '.swift'
    end
  end

  def self.imageset_path_from_resource_name(project_path, resource_name)
    all_dir = Dir.glob(project_path + '**/*').map do |file|
      File.dirname(file)
    end.uniq
    all_dir.select do |dir|
      dir.include?(resource_name + '.imageset')
    end[0]
  end
end

#p ProjectUtils.list_all_xib('/Users/kento/ios/HatalikeSwift/HatalikeSwift/')
#p ProjectUtils.list_all_storyboard('/Users/kento/ios/HatalikeSwift/HatalikeSwift/')

# p ProjectUtils.imageset_path_from_resource_name('/Users/kento/ios/HatalikeSwift/HatalikeSwift/', 'checkbox')
