# frozen_string_literal: true

class Transactions
  def initialize(source:)
    @source = source
    @filename = source[:filename]
    @header = Header::Transaction.new(fields: csv_source.first)
    @items = build_source_items
  end

  attr_reader :header, :items, :filename

  private

  attr_reader :source

  def build_source_items
    csv_source[1..-1].map { |transaction| Transaction.new(cleared(transaction)) }.sort_by(&:donated_at)
  end

  def csv_source
    @csv_source ||= CSV.parse(ClearCsvFile.new(file: source[:tempfile]).call, col_sep: ';')
  end

  def cleared(transaction)
    {
      email: fetch_transaction_email(transaction),
      name: fetch_transaction_name(transaction),
      amount: transaction[header.index_amount],
      currency: transaction[header.index_currency],
      donated_at: fetch_transaction_donated_at(transaction),
      target: transaction[header.index_target],
      type: fetch_transaction_type(transaction)
    }
  end

  def fetch_transaction_email(transaction)
    index_of_email = header.index_email
    index_of_payer = header.index_payer
    email_index_of_email = fix_to_string(transaction[index_of_email])
    email_index_of_email.empty? ? fix_to_string(transaction[index_of_payer]) : email_index_of_email
  end

  def fetch_transaction_name(transaction)
    fix_to_string(transaction[header.index_name])
  end

  def fix_to_string(value)
    value.to_s.strip
  end

  def fetch_transaction_donated_at(transaction)
    Time.parse(transaction[header.index_donated_at]).strftime('%F %H:%M')
  end

  def fetch_transaction_type(transaction)
    transaction[header.index_type]
  end
end
