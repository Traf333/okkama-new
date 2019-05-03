# frozen_string_literal: true

class Source
  attr_accessor :email, :name, :status, :match_type

  def initialize(email:, name:, status: nil, match_type: nil)
    @email = email
    @name = name
    @status = status
    @match_type = match_type
  end

  def email_prefix
    email.to_s.split('@').first.to_s.downcase
  end

  def in(transactions)
    transactions.select { |transaction| transaction.valid? && match?(transaction) }
  end

  def match?(transaction)
    return true if match_by_email?(transaction)
    return true if match_by_name?(transaction)

    false
  end

  def to_a
    Transaction::HEADER_FIELDS.map do |field|
      respond_to?(field) ? public_send(field) : ''
    end
  end

  private

  def match_by_email?(transaction)
    !email_prefix.empty? && transaction.email_prefix == email_prefix
  end

  def match_by_name?(transaction)
    !name.empty? && !blacklist.match?(transaction.name) && transaction.name == name
  end

  def blacklist
    /momentum/i
  end
end
