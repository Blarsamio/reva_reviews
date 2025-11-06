class Review < ApplicationRecord
  before_validation :generate_fingerprint

  private

  def generate_fingerprint
    return if fingerprint.present?

    # normalizing data for fingerprint generation
    # and ensuring we handle nil values
    data = [
      company_name.to_s.strip ,
      review_date&.iso8601,
      rating.to_s,
      channel.to_s.strip, 
      description.to_s.strip,
    ].join('|')

    self.fingerprint = Digest::SHA256.hexdigest(data)
  end
end
