module Review::Filterable
  extend ActiveSupport::Concern

  included do
    scope :by_rating, ->(ratings) { where(rating: ratings) if ratings.present? }
    scope :by_channel, ->(channels) { where(channel: channels) if channels.present? }
    scope :by_company, -> (name) { where("company_name ILIKE ?", "%#{name}%") if name.present? }
    scope :by_date_range, ->(start_date, end_date) { where(review_date: start_date..end_date) if start_date.present? && end_date.present? }
  end

  class_methods do
    def filtered(params)
      scope = all
      scope = scope.by_rating(params[:ratings])
      scope = scope.by_channel(params[:channels])
      scope = scope.by_company(params[:company_name])
      scope = scope.by_date_range(params[:start_date], params[:end_date])
      scope = scope.search_by_description(params[:query]) if params[:query].present?
      scope
    end
  end
end