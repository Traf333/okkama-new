# frozen_string_literal: true

require 'hanami/interactor'
require 'zip'

module Okkama
  module Interactors
    class GenerateFondReport
      include Hanami::Interactor

      expose :zip_file

      def initialize(params:)
        @source = CSV.read(params.dig(:source, :tempfile), col_sep: ';')
        @reports = params[:reports].map do |report|
          { list: CSV.read(report[:tempfile], col_sep: ';'), filename: report[:filename] }
        end
        @encoding = params[:encoding]
        @temp_files = []
      end

      def call
        temp_zip = Tempfile.new(%w[reports .zip])
        temp_files << temp_zip
        ::Zip::File.open(temp_zip.path, Zip::File::CREATE) do |zip|
          reports.each do |report|
            build_result(report, zip)
          end
          create_csv_to_zip(zip, unmatched_transactions, 'unmatched_transactions.csv')
        end
        @zip_file = File.read(temp_zip.path)
        unlink_temp_files
      end

      private

      attr_reader :source, :reports, :encoding
      attr_accessor :temp_files

      def unlink_temp_files
        temp_files.each do |temp_file|
          temp_file.close
          temp_file.unlink
        end
      end

      # Build Report
      def report_items(report)
        header = Header.new(fields: report.first)
        report[1..-1].map do |row|
          Source.new(email: row[header.index_email].to_s, name: row[header.index_name].to_s)
        end.compact
      end

      def build_result(report, zip)
        result = []
        report_items(report[:list]).each do |item|
          transaction_search(result, item)
        end
        create_csv_to_zip(zip, result, report[:filename])
      end

      def transaction_search(result, item)
        found_transactions = item.in(transactions)
        return not_found_transactions(result, item) unless found_transactions.any?

        found_transactions.each_with_index do |transaction, index|
          transaction.match_type = index.zero? ? 'matched' : 'repeated'
          transaction.email = item.email if transaction.email.empty?
          result << transaction
        end
      end

      def create_csv_to_zip(zip, result, filename)
        csv_file = Tempfile.new([filename, '.csv'])
        temp_files << csv_file
        CSV.open(csv_file.path, 'w', encoding: encoding, col_sep: ';') do |csv|
          csv << Transaction::HEADER_FIELDS
          result.each do |transaction|
            csv << transaction.to_a
          end
        end
        zip.add(filename, csv_file.path)
      end

      def not_found_transactions(result, item)
        item.match_type = 'not matched'
        result << item
      end

      # Build Transactions
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

      # Missing Transactions
      def unmatched_transactions
        transactions.select { |transaction| transaction.match_type.to_s.empty? }
      end
    end
  end
end
