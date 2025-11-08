module NpsHelper
  # realized that i could extract all this heavy logic from views
  # to turn the appropriate color class based on nps here

  def nps_color_class(score)
    if score >= 50
      'text-green-600'
    elsif score >= 0
      'text-yellow-600'
    else
      'text-red-600'
    end
  end

  def nps_label(score)
    if score >= 70
      'Excellent'
    elsif score >= 50
      'Great'
    elsif score >= 30
      'Good'
    elsif score >= 0
      'Fair'
    else
      'Needs Improvement'
    end
  end

  def nps_label_color_class(score)
    if score >= 50
      'text-green-600'
    elsif score >= 0
      'text-yellow-600'
    else
      'text-red-600'
    end
  end

  def format_nps_score(score)
    score > 0 ? "+#{score}" : score.to_s
  end

  def format_percentage(count, total)
    return 0 if total.zero?
    (count.to_f / total * 100).round
  end

  def nps_total_count(nps_score)
    return 0 unless nps_score

    nps_score.promoter_count + nps_score.passive_count + nps_score.detractor_count
  end

  def nps_has_data?(nps_score)
    nps_score && nps_total_count(nps_score).positive?
  end
end
