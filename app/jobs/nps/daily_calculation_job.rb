class Nps::DailyCalculationJob < ApplicationJob
  queue_as :default

  def perform(date = Date.yesterday)
    Nps::DailyCalculator.new(date).aggregate
  end
end