require 'rails_helper'

RSpec.describe Note, type: :model do
  describe 'associations' do
    it { should belong_to(:notebook) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
  end

  describe 'default scope' do
    it 'orders notes by position' do
      notebook = create(:notebook)
      note1 = create(:note, notebook: notebook, position: 2)
      note2 = create(:note, notebook: notebook, position: 0)
      note3 = create(:note, notebook: notebook, position: 1)

      expect(notebook.notes.to_a).to eq([ note2, note3, note1 ])
    end
  end

  describe '#calculate_content_size' do
    it 'calculates content size before saving' do
      note = build(:note, content: 'Hello World')
      note.save

      expect(note.content_size).to eq('Hello World'.bytesize)
    end

    it 'updates content size when content changes' do
      note = create(:note, content: 'Short')
      original_size = note.content_size

      note.update(content: 'Much longer content here')

      expect(note.content_size).to be > original_size
      expect(note.content_size).to eq('Much longer content here'.bytesize)
    end

    it 'handles empty content' do
      note = create(:note, content: '')
      expect(note.content_size).to eq(0)
    end

    it 'handles unicode content correctly' do
      unicode_content = '🎉 Hello 世界'
      note = create(:note, content: unicode_content)

      expect(note.content_size).to eq(unicode_content.bytesize)
    end
  end

  describe '#rendered_content' do
    it 'converts markdown to HTML' do
      note = create(:note, content: '# Hello World')

      expect(note.rendered_content).to include('<h1')
      expect(note.rendered_content).to include('Hello World')
    end

    it 'handles bold text' do
      note = create(:note, content: '**bold text**')

      expect(note.rendered_content).to include('<strong>')
      expect(note.rendered_content).to include('bold text')
    end

    it 'handles italic text' do
      note = create(:note, content: '*italic text*')

      expect(note.rendered_content).to include('<em>')
      expect(note.rendered_content).to include('italic text')
    end

    it 'handles code blocks' do
      note = create(:note, content: '`code here`')

      expect(note.rendered_content).to include('<code>')
      expect(note.rendered_content).to include('code here')
    end

    it 'handles links' do
      note = create(:note, content: '[Google](https://google.com)')

      expect(note.rendered_content).to include('<a')
      expect(note.rendered_content).to include('href="https://google.com"')
      expect(note.rendered_content).to include('Google')
    end

    it 'handles lists' do
      content = "- Item 1\n- Item 2\n- Item 3"
      note = create(:note, content: content)

      expect(note.rendered_content).to include('<ul>')
      expect(note.rendered_content).to include('<li>')
      expect(note.rendered_content).to include('Item 1')
    end

    it 'handles empty content' do
      note = create(:note, content: '')
      expect(note.rendered_content).not_to be_nil
    end
  end
end
