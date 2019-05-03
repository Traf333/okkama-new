# frozen_string_literal: true

require 'hanami/interactor'

module Okkama
  module Interactors
    class GenerateFondReport
      include Hanami::Interactor

      expose :csv

      def initialize(params:)
        @source = CSV.read(params.dig(:source, :tempfile), col_sep: ';')
        @report = CSV.read(params.dig(:report, :tempfile), col_sep: ';')
        @result = []
      end

      def call
        report_items.each(&method(:transaction_search))
        @csv = build_result_csv
        # write_file(result, report[:namespace])
        # write_file(unmatched_transactions, 'unmatched.csv')
      end

      private

      attr_reader :source, :report
      attr_accessor :result

      def build_result_csv
        CSV.generate(col_sep: ';') do |csv|
          csv << Transaction::HEADER_FIELDS
          result.each do |transaction|
            csv << transaction.to_a
          end
          unmatched_transactions.each do |transaction|
            csv << transaction.to_a
          end
        end
      end

      def report_items
        header = Header.new(fields: report.first)
        report[1..-1].map do |row|
          Source.new(email: row[header.index_email].to_s, name: row[header.index_name].to_s)
        end.compact
      end

      def transaction_search(item)
        found_transactions = item.in(transactions)
        return not_found_transactions(item) unless found_transactions.any?

        found_transactions.each_with_index do |transaction, index|
          transaction.match_type = index.zero? ? 'matched' : 'repeated'
          transaction.email = item.email if transaction.email.empty?
          result << transaction
        end
      end

      def not_found_transactions(item)
        item.match_type = 'not matched'
        result << item
      end

      def transactions
        @transactions ||= source[1..-1].map { |row| Transaction.new(cleared(row)) }.sort_by(&:donated_at)
      end

      def cleared(row)
        {
          email: fetch_transaction_email(row),
          name: fetch_transaction_name(row),
          amount: row[transactions_header.index_amount],
          currency: row[transactions_header.index_currency],
          donated_at: fetch_transaction_donated_at(row),
          target: row[transactions_header.index_target],
          type: fetch_transaction_type(row)
        }
      end

      def transactions_header
        @transactions_header ||= Header.new(fields: source.first)
      end

      def fetch_transaction_email(row)
        index_of_email = transactions_header.index_email
        index_of_payer = transactions_header.index_payer
        row[index_of_email].to_s.empty? ? row[index_of_payer] : row[index_of_email]
      end

      def fetch_transaction_name(row)
        row[transactions_header.index_name].to_s
      end

      def fetch_transaction_donated_at(row)
        Time.parse(row[transactions_header.index_donated_at]).strftime('%F %H:%M')
      end

      def fetch_transaction_type(row)
        row[transactions_header.index_type]
      end

      def unmatched_transactions
        transactions.select { |transaction| transaction.match_type.to_s.empty? }
      end

      # def write_file(result, pathname)
      #   CSV.open("build/#{Date.today}/#{pathname}", 'w', encoding: 'windows-1251:utf-8', col_sep: ';') do |csv|
      #     csv << HEADERS
      #     result.each do |transaction|
      #       csv << transaction.to_a
      #     end
      #   end
      # end
    end
  end
end
