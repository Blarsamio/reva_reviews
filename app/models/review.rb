class Review < ApplicationRecord
  include Searchable
  include Filterable
  before_validation :generate_fingerprint

  # keeeping NPS logic here since it's core domain behavior
  # but could be extracted to a concern maybe, if it becomes more complex
  def promoter?
    rating == 5
  end

  def passive?
    rating == 4
  end

  def detractor?
    rating <= 3
  end

  def nps_category
    return :promoter if promoter?
    return :passive if passive?
    return :detractor if detractor?
    nil
  end

  private

  def generate_fingerprint
    return if fingerprint.present?

    # normalizing data for fingerprint generation
    # and ensuring we handle nil values
    data = [
      company_name.to_s.strip,
      review_date&.iso8601,
      rating.to_s,
      channel.to_s.strip,
      description.to_s.strip
    ].join('|')

    self.fingerprint = Digest::SHA256.hexdigest(data)
  end
end
