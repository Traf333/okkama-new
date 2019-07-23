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
      ReportItem.new(report_item_params(row))
    end.compact
  end

  def report_item_params(row)
    {
      email: fix_to_string(row[header.index_email]),
      name: fix_to_string(row[header.index_name])
    }
  end

  def fix_to_string(value)
    value.to_s.strip
  end

  def csv_report
    @csv_report ||= CSV.parse(ClearCsvFile.new(file: report[:tempfile]).call, col_sep: ';')
  end
end
