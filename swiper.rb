class Swiper

  STARTING_SCORE = 0
  RIGHT_SWIPE_THRESHOLDS = { low: -2, medium_low: 0, medium: 2, medium_high: 4, high: 6 } # These values are arbitrary and will be tweaked

  attr_accessor :selectiveness, :classifier

  def initialize(selectiveness: :medium_high, connection:)
    @right_swipe_threshold = RIGHT_SWIPE_THRESHOLDS[selectiveness]
    raise UnknownSelectivenessLevel("#{selectiveness} is not a valid level") unless @right_swipe_threshold
    @conn = connection
    training_data = File.read('classifier.dat')
    @classifier = Marshal.load(training_data)
  end

  def swipe(profile)
    text = profile.all_text
    verdict = classifier.classify(profile.all_text)
    verdict == 'Swipe right' ? swipe_right(profile) : swipe_left(profile)
  end

  def swipe_right(profile)
    @conn.get 'like/' + profile.id
  end

  def swipe_left(profile)
    @conn.get 'pass/' + profile.id
  end

  class UnknownSelectivenessLevel < StandardError; end
  class SwipeError < StandardError; end
end
