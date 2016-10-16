class SwipeCriterion

  def initialize(content_string:, value:)
    raise(InvalidSwipeCriterion, 'Content must be a string of at least 3 characters') unless content_string.is_a?(String) && content_string.length >= 3
    raise(InvalidSwipeCriterion, 'Value must be an integer') unless value.is_a?(Integer)
    @content_string = content_string
    @value = value
  end
end