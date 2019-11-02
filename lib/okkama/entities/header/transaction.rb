# frozen_string_literal: true

module Header
  class Transaction < Header::Base
    def index_name
      fields.index { |str| str.match(/name|имя/i) }
    end
  end
end
