require 'rails_helper'

RSpec.describe Notebook, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:notes).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:color) }
    it { should validate_inclusion_of(:color).in_array(%w[black red green blue yellow orange]) }
  end

  describe 'default scope' do
    it 'orders notebooks by position' do
      user = create(:user)
      user.notebooks.destroy_all # Clear default notebooks
      
      notebook1 = create(:notebook, user: user, position: 2)
      notebook2 = create(:notebook, user: user, position: 0)
      notebook3 = create(:notebook, user: user, position: 1)

      expect(user.notebooks.reload.to_a).to eq([notebook2, notebook3, notebook1])
    end
  end

  describe '#hex_color' do
    it 'returns correct hex code for black' do
      notebook = build(:notebook, color: 'black')
      expect(notebook.hex_color).to eq('#1f2937')
    end

    it 'returns correct hex code for red' do
      notebook = build(:notebook, color: 'red')
      expect(notebook.hex_color).to eq('#ef4444')
    end

    it 'returns correct hex code for green' do
      notebook = build(:notebook, color: 'green')
      expect(notebook.hex_color).to eq('#22c55e')
    end

    it 'returns correct hex code for blue' do
      notebook = build(:notebook, color: 'blue')
      expect(notebook.hex_color).to eq('#3b82f6')
    end

    it 'returns correct hex code for yellow' do
      notebook = build(:notebook, color: 'yellow')
      expect(notebook.hex_color).to eq('#eab308')
    end

    it 'returns correct hex code for orange' do
      notebook = build(:notebook, color: 'orange')
      expect(notebook.hex_color).to eq('#f97316')
    end

    it 'returns blue hex code for invalid color' do
      notebook = build(:notebook)
      # Bypass validation to test fallback
      notebook.color = 'invalid'
      notebook.save(validate: false)
      
      expect(notebook.hex_color).to eq('#3b82f6')
    end
  end

  describe 'deleting notebook' do
    it 'deletes associated notes when notebook is deleted' do
      notebook = create(:notebook, :with_notes)
      note_ids = notebook.notes.pluck(:id)
      
      expect { notebook.destroy }.to change { Note.count }.by(-3)
      expect(Note.where(id: note_ids)).to be_empty
    end
  end
end
