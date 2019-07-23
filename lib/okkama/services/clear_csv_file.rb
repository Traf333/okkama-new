# frozen_string_literal: true

class ClearCsvFile
  def initialize(file:)
    @file = file
  end

  def call
    File.read(file).gsub(/\n+|\r+/, "\n").squeeze("\n").strip
  end

  private

  attr_reader :file
end
