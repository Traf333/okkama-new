# frozen_string_literal: true

class ReportItems
  def initialize(report:)
    @report = report
    @filename = report[:filename]
    @header = Header.new(fields: csv_report.first)
    @items = build_report_items
  end

  attr_reader :header, :items, :filename

  private

  attr_reader :report

  def build_report_items
    csv_report[1..-1].map do |row|
      ReportItem.new(email: row[header.index_email].to_s, name: row[header.index_name].to_s)
    end.compact
  end

  def csv_report
    @csv_report ||= CSV.read(report[:tempfile], col_sep: ';')
  end
end
