class CreateNpsScores < ActiveRecord::Migration[7.1]
  def change
    create_table :nps_scores do |t|
      t.date :date, null: false
      t.string :company # keeping this as nullable so i can have global scores easily
      t.integer :promoter_count, default: 0
      t.integer :passive_count, default: 0
      t.integer :detractor_count, default: 0
      t.integer :score

      t.timestamps

      t.index [:date, :company], unique: true #to prevent possible dups
    end
  end
end
