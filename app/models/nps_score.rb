class NpsScore < ApplicationRecord
  validates :date, presence: true, uniqueness: { scope: :company }

  scope :global, -> { where(company: nil) }
  scope :by_company, -> { where.not(company: nil)}
  scope :for_company, ->(name) { where(company: name) }
  scope :for_date, ->(date) { where(date: date) }

  before_save :set_score

  def calculate_nps
    total = promoter_count + passive_count + detractor_count
    return 0 if total.zero?

    # if I understand correctly, passives don't count on NPS score system
    # so I can't keep them into account for numerator
    ((promoter_count - detractor_count) / total.to_f * 100)
  end

  private

  def set_score
    self.score = calculate_nps
  end
end