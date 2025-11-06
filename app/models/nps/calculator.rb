class Nps::Calculator
  def initialize(date:, company: nil)
    @date = date
    @company = company
  end

  def calculate
    conditions = { review_date: @date }
    conditions[:company_name] = @company if @company.present?
    reviews = Review.where(conditions)

    promoter_count = reviews.count { |r| r.promoter? }
    passive_count = reviews.count { |r| r.passive? }
    detractor_count = reviews.count { |r| r.detractor? }

    # find or initialize by to prevent idempotency
    # this words sounds a lot like impotency
    nps = NpsScore.find_or_initialize_by(date: @date, company: @company)
    nps.promoter_count = promoter_count
    nps.passive_count = passive_count
    nps.detractor_count = detractor_count
    nps.save!

    nps
  end

  private

  attr_reader :date, :company
end