class CreateReviews < ActiveRecord::Migration[7.1]
  def change
    enable_extension 'pg_trgm'
  
    create_table :reviews do |t|
      t.string :company_name, null: false
      t.string :channel, null: false
      t.integer :rating, null: false
      t.date :review_date, null: false
      t.string :title
      t.text :description
      t.string :fingerprint, null: false

      t.timestamps
    end
    add_index :reviews, :fingerprint, unique: true
    add_index :reviews, :company_name
    add_index :reviews, :channel
    add_index :reviews, :rating
    add_index :reviews, :review_date
    # using psql's GIST index for trigram search
    add_index :reviews, :description, using: :gist, opclass: :gist_trgm_ops
  end
end
