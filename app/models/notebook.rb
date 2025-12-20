class Notebook < ApplicationRecord
  belongs_to :user
  has_many :notes, dependent: :destroy

  validates :name, presence: true
  validates :color, presence: true, inclusion: { in: %w[black red green blue yellow orange] }

  default_scope { order(position: :asc) }

  COLORS = {
    "black" => "#1f2937",
    "red" => "#ef4444",
    "green" => "#22c55e",
    "blue" => "#3b82f6",
    "yellow" => "#eab308",
    "orange" => "#f97316"
  }.freeze

  def hex_color
    COLORS[color] || COLORS["blue"]
  end
end
