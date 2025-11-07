class ReviewsController < ApplicationController
  def index
    @pagy, @reviews = pagy(Review.filtered(filter_params))
    @channels = Review.all.pluck(:channel).uniq
    date = Date.new(2025, 02, 03)
    nps_loader = Nps::ScoreLoader.new(date)
    @global_nps = nps_loader.global_score
    @company_nps = nps_loader.company_scores
  end

  private

  def filter_params
    params.permit(:company_name, :query, :start_date, :end_date, ratings: [], channels: [])
  end
end
