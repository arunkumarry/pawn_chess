class Player < ApplicationRecord
  belongs_to :game

  validates :name, presence: true
  validates :indicator, presence: true, inclusion: { in: [1, 2] }
  validates :player_type, inclusion: { in: ["human", "bot"] }, allow_nil: true

  def bot?
    player_type == "bot"
  end

  def type
    player_type
  end
end
