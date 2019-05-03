# frozen_string_literal: true

class TempFiles
  def initialize
    @files = []
  end

  attr_reader :files

  def destroy_all
    files.each do |file|
      file.close
      file.unlink
    end
  end

  def create(filename)
    files << Tempfile.new(filename)
    files.last
  end

  private

  attr_writer :files
end
