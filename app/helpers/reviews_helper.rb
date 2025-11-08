module ReviewsHelper
  def rating_stars(rating)
    filled = '<i class="fa-solid fa-star text-amber-300"></i>' * rating
    empty = '<i class="fa-regular fa-star text-amber-100"></i>' * (5- rating)
    (filled + empty).html_safe
  end

  def formatted_review_date(date)
    return '' if date.nil?

    date = date.to_date if date.respond_to?(:to_date)
    days_ago = (Date.today - date).to_i

    case days_ago
    when 0
      'Today'
    when 1
      'Yesterday'
    when 2..6
      "#{days_ago} days ago"
    else
      date.strftime('%b %d, %Y')
    end
  end
end
