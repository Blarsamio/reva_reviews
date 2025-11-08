module Review::Importable
  extend ActiveSupport::Concern

  class_methods do
    def import_from_csv(file_path)
      Review::CsvImporter.new(file_path).import
    end
  end
end
