require "csv"

class ImportCsvService
  BATCH_SIZE = 1000

  attr_reader :table_name, :csv_path, :validate

  def initialize table_name, csv_path, validate = true
    @table_name = table_name
    @csv_path = csv_path
    @validate = validate
  end

  def execute
    ActiveRecord::Base.transaction do
      model.delete_all
      model.import records, batch_size: BATCH_SIZE, validate: validate
    end
  rescue StandardError => e
    Rails.logger.error e.message
  end

  private

  def model
    @model ||= table_name.classify.constantize
  end

  def records
    @records ||= CSV.foreach(csv_path, headers: true).map do |row|
      model.new row.to_hash
    end
  end
end
