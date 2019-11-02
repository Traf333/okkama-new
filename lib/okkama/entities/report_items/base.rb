# frozen_string_literal: true

module ReportItems
  class Base
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
      report_item_class = "ReportItem::#{type_report.split('_')[1..-1].map(&:capitalize).join}"
      csv_report[1..-1].map do |row|
        Object.const_get(report_item_class).new(report_item_params(row))
      end.compact
    end

    def report_item_params(_row)
      raise NotImplementedError
    end

    def fix_to_string(value)
      value.to_s.strip
    end

    def csv_report
      @csv_report ||= CSV.parse(ClearCsvFile.new(file: report[:tempfile]).call, col_sep: ';')
    end
  end
end
