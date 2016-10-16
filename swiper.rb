class Swiper

  STARTING_SCORE = 0
  RIGHT_SWIPE_THRESHOLDS = { low: -2, medium_low: 0, medium: 2, medium_high: 4, high: 6 } # These values are arbitrary and will be tweaked

  attr_accessor :selectiveness

  def initialize(selectiveness: :medium_high)
    @right_swipe_threshold = RIGHT_SWIPE_THRESHOLDS[selectiveness]
    raise UnknownSelectivenessLevel("#{selectiveness} is not a valid level") unless @right_swipe_threshold
  end

  def swipe(profile)
    text = profile.all_text
    #trsp = @conn.get 'like/'+target["_id"] # this would be to swipe right
  end

  class UnknownSelectivenessLevel < StandardError; end
  class SwipeError < StandardError; end
end