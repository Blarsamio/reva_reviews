class Nps::DailyCalculator
  def initialize(date)
    @date = date
  end

  def aggregate
    companies = Review.where(review_date: @date)
                      .where.not(company_name: [nil, ""])
                      .distinct
                      .pluck(:company_name)
    results = []
    # adding to results those with company names and w/o
    
    results << Nps::Calculator.new(date: @date, company: nil).calculate
    companies.each do |c|
      results << Nps::Calculator.new(date: @date, company: c).calculate
    end
    results
  end
end