# frozen_string_literal: true

require 'hanami/interactor'

module Okkama
  module Interactors
    class GenerateFondReport
      include Hanami::Interactor
      HEADERS = %w[email name amount currency donated_at target type match_type].freeze

      def initialize(params:)
        @source = CSV.read(params[:source], col_sep: ';')
        @reports = params[:reports].map do |report|
          { list: CSV.read(report, col_sep: ';'), namespace: report.split('/').last }
        end
      end

      def call
        reports.each do |report|
          result = []

          report_items(report[:list]).each do |item|
            found = item.in(transactions)
            if found.any?
              found.each_with_index do |tr, i|
                tr.match_type = i.zero? ? 'matched' : 'repeated'
                tr.email = item.email if tr.email.empty?
                result << tr
              end
            else
              item.match_type = 'not matched'
              result << item
            end
          end
          write_file(result, report[:namespace])
        end

        unmatched_transactions = transactions.select { |t| t.match_type.to_s.empty? }
        write_file(unmatched_transactions, 'unmatched.csv')
      end

      private

      attr_reader :source, :reports

      def report_items(report)
        header = Header.new(report.first)
        report[1..-1].map do |tr|
          Source.new(tr[header.email].to_s, tr[header.name].to_s)
        end.compact
      end

      def transactions
        @transactions ||= source[1..-1].map do |tr|
          Transaction.new(*cleared(tr))
        end.sort_by(&:donated_at)
      end

      def write_file(result, pathname)
        CSV.open("build/#{Date.today}/#{pathname}", 'w', encoding: 'windows-1251:utf-8', col_sep: ';') do |csv|
          csv << HEADERS
          result.each do |transaction|
            csv << transaction.to_a
          end
        end
      end

      def cleared(row)
        header = Header.new(source.first)
        [
          row[header.email].to_s.empty? ? row[header.payee] : row[header.email],
          row[header.name].to_s,
          row[header.amount],
          row[header.currency],
          Time.parse(row[header.donated_at]).strftime('%F %H:%M'),
          row[header.target],
          row[header.type].to_s
        ]
      end

      Source = Struct.new(:email, :name, :status, :match_type) do
        def email_prefix
          email.to_s.split("@").first.to_s.downcase
        end

        def in(transactions)
          transactions.select { |transaction| transaction.valid? && match?(transaction) }
        end

        def match?(transaction)
          return true if !email_prefix.empty? && transaction.email_prefix == email_prefix
          return true if !name.empty? && !blacklist.match?(transaction.name) && transaction.name == name

          return false
        end

        def to_a
          HEADERS.map do |d|
            self.respond_to?(d) ? self.send(d) : ""
          end
        end

        private

        def blacklist
          /momentum/i
        end
      end

      Transaction = Struct.new(:email, :name, :amount, :currency, :donated_at, :target, :type, :match_type) do
        def email_prefix
          email.to_s.split("@").first.to_s.downcase
        end

        def valid?
          ["Оплата", "Оплата с созданием подписки"].include?(type)
        end

        def to_a
          HEADERS.map { |d| self.send(d) }
        end
      end

      Header = Struct.new(:fields) do
        def name
          fields.index { |str| str.match(/name|имя/i) }
        end

        def email
          fields.index { |str| str.match(/mail/i) }
        end

        def payee
          fields.index { |str| str.match(/плательщик/i) }
        end

        def amount
          fields.index { |str| str.match(/сумма/i) }
        end

        def currency
          fields.index { |str| str.match(/валюта/i) }
        end

        def donated_at
          fields.index { |str| str.match(/дата/i) }
        end

        def target
          fields.index { |str| str.match(/назначение/i) }
        end

        def type
          fields.index { |str| str.match(/тип/i) }
        end

        def status
          fields.index { |str| str.match(/status/i) }
        end
      end
    end
  end
end
