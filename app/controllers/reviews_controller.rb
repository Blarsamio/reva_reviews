class ReviewsController < ApplicationController
  def index
    @pagy, @reviews = pagy(Review.all) 
  end
end
