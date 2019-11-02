# frozen_string_literal: true

module ReportItem
  class Base
    attr_accessor :email, :name, :status, :match_type

    def initialize(params)
      @email = params[:email]
      @name = params[:name]
      @status = params[:status]
      @match_type = params[:match_type]
      post_initialize(params)
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

    attr_reader :type_report

    def post_initialize(_params)
      nil
    end

    def match_by_email?(transaction)
      !email_prefix.empty? && transaction.email_prefix == email_prefix
    end

    def match_by_name?(_transaction)
      raise NotImplementedError
    end

    def fix_for_comparison(value)
      value.strip.downcase.split(' ').sort.join(' ')
    end

    def name_not_empty?
      !name.to_s.empty?
    end

    def blacklist
      /(momentum|visa cardholder|visa cerdholder|master account|no name|анонимно|друг)/i
    end
  end
end
