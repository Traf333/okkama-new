# frozen_string_literal: true

module Header
  class ReportMailChimp < Header::Base
    def index_name
      fields.index { |str| str.match(/имя полное/i) }
    end

    def index_surname
      fields.index { |str| str.match(/фамилия/i) }
    end
  end
end
