# frozen_string_literal: true

module ReportItem
  class SendPulse < ReportItem::Base
    private

    def match_by_name?(transaction)
      name_not_empty? &&
        !blacklist.match?(transaction.name) &&
        fix_for_comparison(transaction.name) == fix_for_comparison(name)
    end
  end
end
