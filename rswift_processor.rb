class RswiftProcessor
  def initialize(filepath)
    @filepath = filepath
    @rename_agendas = []
    @noop = false
  end
  attr_accessor :rename_agendas

  def run(noop: false)
    @noop = noop

    file = File.read(@filepath).split("\n")
    file.each do |line|
      line.gsub!(/R\.image\.([^\(\)]+)/) do
        'R.image.' + rename(Regexp.last_match(1))
      end
    end
    # TODO: empty lineはどうなる？
    File.write(@filepath, file.join("\n") + "\n") unless @noop
  end

  private

  def rename(_original_name)
    raise NotImplementedError, "You must implement #{self.class}##{__method__}"
  end
end
