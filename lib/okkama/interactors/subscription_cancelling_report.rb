# frozen_string_literal: true

require 'hanami/interactor'
require 'zip'

class SubscriptionCancellingReport
  include Hanami::Interactor

  expose :body

  def initialize(params:)
    @transactions = []
    @reports = []
    CSV.foreach(params[:transactions][:tempfile].path, headers: true, col_sep: ';') do |row|
      @transactions << row.to_hash.slice('Email', 'Статус')
    end

    options = { headers: true }
    options[:col_sep] = ';' unless params[:type_report] == 'report_mail_chimp'
    options[:encoding] = 'UTF-8' unless params[:type_report] == 'report_mail_chimp'

    CSV.foreach(params[:report][:tempfile].path, options) do |row|
      if params[:type_report] == 'report_mail_chimp'
        @reports << row.to_hash['Email Address'].strip if row.to_hash['TAGS'].to_s.include?('"Рекуррент"')
      else
        @reports << row.to_hash[' email'].strip
      end
    end

    @matched = []
  end

  def call
    @body = CSV.generate(col_sep: ';') do |csv|
      csv << %w[Email Status]
      transactions.each do |item|
        csv << [email(item), matched?(item) ? 'matched' : nil]
      end
    end
  end

  private

  attr_reader :transactions, :reports, :matched

  def matched?(item)
    %w[Отменена Отклонена].include?(item['Статус']) && !other_subscription?(email(item)) && reports.include?(email(item))
  end

  def other_subscription?(email)
    transactions.any? { |i| email(i) == email && %w[Работает Просрочена].include?(i['Статус']) }
  end

  def email(item)
    item['Email'] || item['Email Address']
  end
end
