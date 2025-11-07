module ReviewsHelper
  def rating_stars(rating)
    filled = '<i class="fa-solid fa-star text-yellow-500"></i>' * rating
    empty = '<i class="fa-regular fa-star text-gray-300"></i>' * (5- rating)
    (filled + empty).html_safe
  end
end
