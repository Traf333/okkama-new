# frozen_string_literal: true

require 'hanami/interactor'
require 'zip'

class GenerateFondReport
  include Hanami::Interactor

  expose :zip_file

  def initialize(params:)
    @transactions = Transactions.new(source: params[:source])
    @reports = params[:reports].map do |report|
      ReportItems.new(report: report)
    end
    @encoding = params[:encoding]
    @temp_files = TempFiles.new
  end

  def call
    @zip_file = build_zip_file
    temp_files.destroy_all
  end

  private

  attr_reader :transactions, :reports, :encoding, :temp_files

  def build_zip_file
    temp_zip = temp_files.create(%w[reports .zip])
    files_to_zip = build_files_to_zip
    ::Zip::File.open(temp_zip.path, Zip::File::CREATE) do |zip|
      files_to_zip.each do |file|
        zip.add(file[:filename], file[:filepath])
      end
    end
    File.read(temp_zip.path)
  end

  def build_files_to_zip
    files_to_zip = []
    reports.each do |report|
      files_to_zip << build_result(report)
    end
    files_to_zip << create_csv_to_zip(not_found_transactions, "not_found_#{transactions.filename}")
    files_to_zip
  end

  # Build Report
  def build_result(report)
    result = []
    report.items.each do |item|
      transaction_search(result, item)
    end
    create_csv_to_zip(result.sort_by(&:email), report.filename)
  end

  def transaction_search(result, item)
    found_transactions = item.in(transactions.items)
    return not_matched_transactions(result, item) unless found_transactions.any?

    found_transactions.each_with_index do |transaction, index|
      transaction.match_type = index.zero? ? 'matched' : 'repeated'
      transaction.email = item.email if transaction.email_empty?
      result << transaction
    end
  end

  def create_csv_to_zip(result, filename)
    csv_file = temp_files.create([filename, '.csv'])
    CSV.open(csv_file.path, 'w', encoding: encoding, col_sep: ';') do |csv|
      csv << Transaction::HEADER_FIELDS
      result.each do |transaction|
        csv << transaction.to_a
      end
    end
    { filepath: csv_file.path, filename: filename }
  end

  def not_matched_transactions(result, item)
    item.match_type = 'not matched'
    result << item
  end

  # Missing Transactions
  def not_found_transactions
    transactions
      .items
      .select(&:match_type_empty?)
      .sort_by(&:email)
  end
end
