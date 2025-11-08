class Review::CsvImporter
  require 'csv'

  def initialize(file_path)
    @file_path = file_path
  end

  def import
    count = 0
    CSV.foreach(@file_path, headers: true) do |row|
      attrs = {
        company_name: row['company_name'],
        channel: row['channel'],
        rating: row['rating'],
        review_date: row['date'],
        title: row['title'],
        description: row['description']
      }

      # will create a temp review to generate fingerprint from model
      # so i can keep dry and
      # since this is an import task an can accept the slight performance cost
      # of creating a temp object
      temp_review = Review.new(attrs)
      temp_review.valid?

      Review.find_or_create_by(fingerprint: temp_review.fingerprint) do |review|
        review.assign_attributes(attrs)
      end
      count += 1
    end
    count
  end
end
