# frozen_string_literal: true

class Transaction
  HEADER_FIELDS = %i[email name amount currency donated_at target type match_type].freeze

  attr_accessor :email, :name, :amount, :currency, :donated_at, :target, :type, :match_type

  def initialize(data)
    HEADER_FIELDS.each { |field| instance_variable_set("@#{field}", data[field]) }
  end

  def email_prefix
    email.to_s.split('@').first.to_s.downcase
  end

  def email_empty?
    email.to_s.empty?
  end

  def match_type_empty?
    match_type.to_s.empty?
  end

  def valid?
    ['Оплата', 'Оплата с созданием подписки'].include?(type)
  end

  def to_a
    HEADER_FIELDS.map(&method(:public_send))
  end
end
