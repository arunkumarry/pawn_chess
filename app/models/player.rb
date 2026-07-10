class Player
  attr_accessor :name, :type, :indicator, :moves_history, :pawns

  def initialize(name: "Test", type: nil, indicator:)
    @name = name
    @type = type
    @indicator = indicator
    @moves_history = []
    @pawns = 16
  end
end
