# frozen_string_literal: true

class Header
  def initialize(fields:)
    @fields = fields
  end

  def index_name
    fields.index { |str| str.match(/name|имя/i) }
  end

  def index_email
    fields.index { |str| str.match(/mail/i) }
  end

  def index_payer
    fields.index { |str| str.match(/плательщик/i) }
  end

  def index_amount
    fields.index { |str| str.match(/сумма/i) }
  end

  def index_currency
    fields.index { |str| str.match(/валюта/i) }
  end

  def index_donated_at
    fields.index { |str| str.match(/дата/i) }
  end

  def index_target
    fields.index { |str| str.match(/назначение/i) }
  end

  def index_type
    fields.index { |str| str.match(/тип/i) }
  end

  def index_status
    fields.index { |str| str.match(/status/i) }
  end

  private

  attr_reader :fields
end
