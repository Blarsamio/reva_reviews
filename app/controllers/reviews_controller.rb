class ReviewsController < ApplicationController
  def index
    @pagy, @reviews = pagy(Review.filtered(filter_params))
    @channels = Review.all.pluck(:channel).uniq
    nps_loader = Nps::ScoreLoader.new(Date.yesterday)
    @global_nps = nps_loader.global_score
    @company_nps = nps_loader.company_scores
  end

  private

  def filter_params
    params.permit(:company_name, :query, :start_date, :end_date, ratings: [], channels: [])
  end
end
