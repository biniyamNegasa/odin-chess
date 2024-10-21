# frozen_string_literal: true

# saves the game
module Database
  def save
    data = Marshal.dump(self)
    Dir.mkdir('output') unless Dir.exist?('output')
    File.open('output/pause.marshal', 'w') do |file|
      file.puts(data)
    end
  end

  def load
    return unless File.exist?('output/pause.marshal')

    file = File.open('output/pause.marshal')
    Marshal.load(file)
  end
end
