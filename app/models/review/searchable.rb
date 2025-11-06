module Review::Searchable
  extend ActiveSupport::Concern

  included do
    include PgSearch::Model

    pg_search_scope :search_by_description,
      against: :description, 
      using: {
        trigram: {
          threshold: 0.3,
          word_similarity: true
        }
      }
  end
end