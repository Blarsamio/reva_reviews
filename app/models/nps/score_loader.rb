class Nps::ScoreLoader
  def initialize(date = Date.yesterday)
    @date = date
  end

  def global_score
    find_or_calculate(company: nil)
  end

  def company_scores
    existing = NpsScore.where(date: @date)
                      .where.not(company: nil)
                      .order(score: :desc)
    if existing.empty?
      calculate_all_scores
      existing = NpsScore.where(date: @date)
                        .where.not(company: nil)
                        .order(score: :desc)
    end
    existing
  end

  private
  
  def find_or_calculate(company: nil)
    NpsScore.find_by(date: @date, company: company) ||
      Nps::Calculator.new(date: @date, company: company).calculate
  end

  def calculate_all_scores
    Nps::DailyCalculator.new(@date).aggregate
  end
end