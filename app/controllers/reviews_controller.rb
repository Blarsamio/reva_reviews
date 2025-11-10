class ReviewsController < ApplicationController
  def index
    @pagy, @reviews = pagy(Review.filtered(filter_params))
    @channels = Review.all.pluck(:channel).uniq
    nps_loader = Nps::ScoreLoader.new(Date.new(2025,02,02)) # passing a fixed dat to get NPS score, otherwise it should be Date.yesterday
    @global_nps = nps_loader.global_score
    @company_nps = nps_loader.company_scores
  end

  private

  # had to add :page because from pagy i was getting unpermitted params :page warning
  def filter_params
    params.permit(:company_name, :query, :start_date, :end_date, :page, ratings: [], channels: [])
  end
end
