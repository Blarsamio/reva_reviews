namespace :reviews do
  desc "Import reviews from a CSV file (idempotent via fingerprint)"
  task :import, [:file_path] => :environment do |_task, args|
    unless args[:file_path]
      puts "Error: Please provide a file path"
      puts "Usage: rake reviews:import[/path/to/reviews.csv]"
      exit 1
    end

    file_path = args[:file_path]

    unless File.exist?(file_path)
      puts "Error: File not found at #{file_path}"
      exit 1
    end

    puts "Starting import from: #{file_path}"
    puts "=" * 60

    initial_count = Review.count
    start_time = Time.current

    begin
      imported_count = Review.import_from_csv(file_path)

      end_time = Time.current
      duration = (end_time - start_time).round(2)
      final_count = Review.count
      new_reviews = final_count - initial_count

      puts "=" * 60
      puts "Import completed successfully"
      puts "Duration: #{duration} seconds"
      puts "Reviews processed: #{imported_count}"
      puts "New reviews created: #{new_reviews}"
      puts "Total reviews in database: #{final_count}"
      puts "=" * 60

      if new_reviews == 0
        puts "No new reviews were added (all reviews already exist)"
        puts "This is expected behavior to prevent idempotency"
      end
    rescue StandardError => e
      puts "=" * 60
      puts "Error during import: #{e.message}"
      puts e.backtrace.first(5).join("\n")
      puts "=" * 60
      exit 1
    end
  end
end
