class ReviewsController < ApplicationController
  def index
    @pagy, @reviews = pagy(Review.filtered(filter_params))
    @channels = Review.all.pluck(:channel).uniq
  end

  private

  def filter_params
    params.permit(:company_name, :query, :start_date, :end_date, ratings: [], channels: [])
  end
end
