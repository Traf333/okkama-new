# frozen_string_literal: true

module ReportItem
  class MailChimp < ReportItem::Base
    attr_reader :surname

    private

    def post_initialize(params)
      @surname = params[:surname]
    end

    def match_by_name?(transaction)
      name_not_empty? &&
        !blacklist.match?(transaction.name) &&
        fix_for_comparison(transaction.name) == fix_for_comparison(name) &&
        name.split(' ').count > 1
    end
  end
end
