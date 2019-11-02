# frozen_string_literal: true

module ReportItems
  class MailChimp < ReportItems::Base
    private

    def report_item_params(row)
      {
        email: fix_to_string(row[header.index_email]),
        name: fix_to_string("#{row[header.index_name]} #{row[header.index_surname]}")
      }
    end
  end
end
