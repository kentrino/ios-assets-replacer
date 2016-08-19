class RswiftProcessor
  def initialize(filepath)
    @filepath = filepath
    @rename_agenda = {}
    @noop = false
  end
  attr_accessor :rename_agenda

  def run(noop: false)
    @noop = noop

    file = File.read(@filepath).split("\n")
    file.each do |line|
      line.gsub!(/R\.image\.([^\(\)]+)/) do
        'R.image.' + rename($1)
      end
    end
    # TODO: empty lineはどうなる？
    if !@noop
      File.write(@filepath, file.join("\n") + "\n")
    end
  end

  private
  def rename(original_name)
    raise NotImplementedError.new("You must implement #{self.class}##{__method__}")
  end
end
