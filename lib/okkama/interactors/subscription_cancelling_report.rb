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
    CSV.foreach(params[:report][:tempfile].path, headers: true, col_sep: ';') do |row|
      @reports << row.to_hash[' email'].strip
    end

    @matched = []
  end

  def call
    @body = CSV.generate(col_sep: ';') do |csv|
      csv << ['Email', 'Статус']
      transactions.each do |item|
        csv << [item['Email'], matched?(item) ? 'matched' : nil]
      end
    end
  end

  private

  attr_reader :transactions, :reports, :matched

  def matched?(item)
    item['Статус'] == 'Отменена' && !other_subscription?(item['Email']) && reports.include?(item['Email'])
  end

  def other_subscription?(email)
    transactions.any? { |i| i['Email'] == email && %w[Работает Просрочена].include?(i['Статус']) }
  end
end
