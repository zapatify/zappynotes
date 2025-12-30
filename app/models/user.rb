class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :notebooks, dependent: :destroy
  has_many :notes, through: :notebooks
  has_one :subscription, dependent: :destroy

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { new_record? || !password.nil? }

  normalizes :email_address, with: -> { _1.strip.downcase }

  after_create :create_default_notebooks

  # Subscription plan limits
  PLAN_LIMITS = {
    free: { notebooks: 3, notes_per_notebook: 10, storage_mb: 100 },
    plus: { notebooks: 10, notes_per_notebook: 30, storage_mb: 500 },
    pro: { notebooks: Float::INFINITY, notes_per_notebook: Float::INFINITY, storage_mb: Float::INFINITY }
  }.freeze

  def plan
    subscription&.plan&.to_sym || :free
  end

  def plan_limits
    PLAN_LIMITS[plan]
  end

  def can_create_notebook?
    return true if admin? # Admins have unlimited notebooks
    notebooks.count < plan_limits[:notebooks]
  end

  def can_create_note?(notebook)
    return true if admin? # Admins have unlimited notes
    notebook.notes.count < plan_limits[:notes_per_notebook]
  end

  def total_storage_used_mb
    (notes.sum(:content_size).to_f / 1_048_576).round(2)
  end

  def can_add_content?(additional_bytes)
    return true if admin? || plan == :pro # Admins and Pro users have unlimited storage
    total_bytes = notes.sum(:content_size) + additional_bytes
    (total_bytes.to_f / 1_048_576) <= plan_limits[:storage_mb]
  end

  def within_storage_limit?
    total_storage_used_mb <= plan_limits[:storage_mb]
  end

  before_create :generate_confirmation_token

  def confirmed?
    confirmed_at.present?
  end

  def confirm!
    update(confirmed_at: Time.current, confirmation_token: nil)
  end

  def send_confirmation_email
    UserMailer.confirmation_email(self).deliver_later
    update(confirmation_sent_at: Time.current)
  end

  def confirmation_token_expired?
    return false if confirmation_sent_at.nil?
    confirmation_sent_at < 24.hours.ago
  end

  private

  def create_default_notebooks
    # Create "My Notebook" with "First Note"
    my_notebook = notebooks.create!(
      name: "My Notebook",
      color: "black",
      position: 0
    )
    my_notebook.notes.create!(
      title: "First Note",
      content: "# Welcome to ZappyNotes!\n\nStart writing your first note here...",
      position: 0
    )

    # Create "Getting Started" notebook with welcome note
    getting_started = notebooks.create!(
      name: "Getting Started",
      color: "black",
      position: 1
    )
    getting_started.notes.create!(
      title: "Welcome to ZappyNotes",
      content: welcome_note_content,
      position: 0
    )
  end

  def welcome_note_content
    <<~MARKDOWN
      # Welcome to ZappyNotes! 🎉

      Thank you for choosing ZappyNotes as your note-taking companion. This guide will help you get started.

      ## Getting Started

      ### Creating Notebooks
      - Click the **"+ Create Notebook"** button at the top of the sidebar
      - Give your notebook a name
      - Choose from 5 colors to organize your notebooks

      ### Managing Notes
      - Select a notebook to see its notes
      - Click **"+ Create Note"** to add a new note
      - Click on any note to start editing

      ### Formatting with Markdown
      ZappyNotes supports GitHub Flavored Markdown for rich text formatting:

      - **Bold text** with `**bold**`
      - *Italic text* with `*italic*`
      - `Code` with backticks
      - [Links](https://example.com) with `[text](url)`
      - Lists, headers, and more!

      ### Auto-Save
      Your notes are automatically saved:
      - When you click outside the editor
      - Every minute while you're typing

      ## Your Plan

      You're currently on the **Free Plan** which includes:
      - 3 notebooks
      - 10 notes per notebook
      - 100MB total storage

      Need more? Check out our Plus ($1.99/month) or Pro ($4.99/month) plans!

      ## Tips
      - Use the ellipsis menu (⋮) next to notebooks to change colors
      - Rename notebooks and notes by clicking the ellipsis menu
      - Organize your notebooks with meaningful colors

      Happy note-taking! ✨
    MARKDOWN
  end

  def generate_confirmation_token
    self.confirmation_token = SecureRandom.urlsafe_base64
  end
end
test = 1
