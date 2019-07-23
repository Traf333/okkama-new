# frozen_string_literal: true

class ReportItems
  def initialize(report:, type_report:)
    header_class = "Header::#{type_report.split('_').map(&:capitalize).join}"
    @type_report = type_report
    @report = report
    @filename = report[:filename]
    @header = Object.const_get(header_class).new(fields: csv_report.first)
    @items = build_report_items
  end

  attr_reader :header, :items, :filename

  private

  attr_reader :report, :type_report

  def build_report_items
    binding.pry
    csv_report[1..-1].map do |row|
      ReportItem.new(report_item_params(row))
    end.compact
  end

  def report_item_params(row)
    {
      email: fix_to_string(row[header.index_email]),
      name: fix_to_string(row[header.index_name]),
      type_report: type_report
    }
  end

  def fix_to_string(value)
    value.to_s.strip
  end

  def csv_report
    @csv_report ||= CSV.parse(ClearCsvFile.new(file: report[:tempfile]).call, col_sep: ';')
  end
end
