class Note < ApplicationRecord
  belongs_to :notebook

  validates :title, presence: true

  before_save :calculate_content_size

  default_scope { order(position: :asc) }

  def rendered_content
    require "kramdown"
    Kramdown::Document.new(content, input: "GFM").to_html.html_safe
  end

  private

  def calculate_content_size
    self.content_size = content.bytesize
  end
end
