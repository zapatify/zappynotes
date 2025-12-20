require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:sessions).dependent(:destroy) }
    it { should have_many(:notebooks).dependent(:destroy) }
    it { should have_many(:notes).through(:notebooks) }
    it { should have_one(:subscription).dependent(:destroy) }
  end

  describe 'validations' do
    subject { create(:user) }
    
    it { should validate_presence_of(:email_address) }
    it { should validate_uniqueness_of(:email_address).ignoring_case_sensitivity }
    it { should allow_value('user@example.com').for(:email_address) }
    it { should_not allow_value('invalid_email').for(:email_address) }
  end

  describe 'callbacks' do
    describe '#create_default_notebooks' do
      it 'creates default notebooks after user creation' do
        user = create(:user)
        
        expect(user.notebooks.count).to eq(2)
        expect(user.notebooks.pluck(:name)).to include('My Notebook', 'Getting Started')
      end

      it 'creates "My Notebook" with first note' do
        user = create(:user)
        my_notebook = user.notebooks.find_by(name: 'My Notebook')
        
        expect(my_notebook).to be_present
        expect(my_notebook.color).to eq('black')
        expect(my_notebook.notes.count).to eq(1)
        expect(my_notebook.notes.first.title).to eq('First Note')
      end

      it 'creates "Getting Started" notebook with welcome note' do
        user = create(:user)
        getting_started = user.notebooks.find_by(name: 'Getting Started')
        
        expect(getting_started).to be_present
        expect(getting_started.color).to eq('black')
        expect(getting_started.notes.count).to eq(1)
        expect(getting_started.notes.first.title).to eq('Welcome to ZappyNotes')
      end
    end
  end

  describe '#plan' do
    it 'returns :free when user has no subscription' do
      user = create(:user)
      expect(user.plan).to eq(:free)
    end

    it 'returns subscription plan when user has subscription' do
      user = create(:user)
      create(:subscription, user: user, plan: :plus)
      
      expect(user.plan).to eq(:plus)
    end
  end

  describe '#plan_limits' do
    it 'returns correct limits for free plan' do
      user = create(:user)
      
      expect(user.plan_limits[:notebooks]).to eq(3)
      expect(user.plan_limits[:notes_per_notebook]).to eq(10)
      expect(user.plan_limits[:storage_mb]).to eq(100)
    end

    it 'returns correct limits for plus plan' do
      user = create(:user)
      create(:subscription, user: user, plan: :plus)
      
      expect(user.plan_limits[:notebooks]).to eq(10)
      expect(user.plan_limits[:notes_per_notebook]).to eq(30)
      expect(user.plan_limits[:storage_mb]).to eq(500)
    end

    it 'returns unlimited limits for pro plan' do
      user = create(:user)
      create(:subscription, user: user, plan: :pro)
      
      expect(user.plan_limits[:notebooks]).to eq(Float::INFINITY)
      expect(user.plan_limits[:notes_per_notebook]).to eq(Float::INFINITY)
      expect(user.plan_limits[:storage_mb]).to eq(Float::INFINITY)
    end
  end

  describe '#can_create_notebook?' do
    context 'for free users' do
      it 'returns true when under limit' do
        user = create(:user)
        # User starts with 2 default notebooks
        
        expect(user.can_create_notebook?).to eq(true)
      end

      it 'returns false when at limit' do
        user = create(:user)
        # User starts with 2 default notebooks, create 1 more to hit limit of 3
        create(:notebook, user: user)
        
        expect(user.can_create_notebook?).to eq(false)
      end
    end

    context 'for admin users' do
      it 'always returns true' do
        user = create(:user, :admin)
        create_list(:notebook, 10, user: user)
        
        expect(user.can_create_notebook?).to eq(true)
      end
    end

    context 'for plus users' do
      it 'returns true when under limit' do
        user = create(:user)
        create(:subscription, user: user, plan: :plus)
        create_list(:notebook, 5, user: user)
        
        expect(user.can_create_notebook?).to eq(true)
      end
    end
  end

  describe '#can_create_note?' do
    let(:user) { create(:user) }
    let(:notebook) { create(:notebook, user: user) }

    context 'for free users' do
      it 'returns true when under limit' do
        create_list(:note, 5, notebook: notebook)
        
        expect(user.can_create_note?(notebook)).to eq(true)
      end

      it 'returns false when at limit' do
        create_list(:note, 10, notebook: notebook)
        
        expect(user.can_create_note?(notebook)).to eq(false)
      end
    end

    context 'for admin users' do
      it 'always returns true' do
        user = create(:user, :admin)
        notebook = create(:notebook, user: user)
        create_list(:note, 20, notebook: notebook)
        
        expect(user.can_create_note?(notebook)).to eq(true)
      end
    end
  end

  describe '#total_storage_used_mb' do
    it 'returns 0 when user has no notes' do
      user = create(:user)
      user.notebooks.destroy_all # Remove default notebooks (and their notes)
      
      expect(user.total_storage_used_mb).to eq(0)
    end

    it 'calculates total storage across all notes' do
      user = create(:user)
      notebook = create(:notebook, user: user)
      
      # Create notes with known content sizes
      note1 = create(:note, notebook: notebook, content: 'a' * 1000) # ~1KB
      note2 = create(:note, notebook: notebook, content: 'b' * 2000) # ~2KB
      
      # Force content_size calculation
      note1.save
      note2.save
      
      expected_mb = (note1.content_size + note2.content_size).to_f / 1_048_576
      expect(user.total_storage_used_mb).to be_within(0.01).of(expected_mb)
    end
  end

  describe '#can_add_content?' do
    let(:user) { create(:user) }

    context 'for free users' do
      it 'returns true when adding content stays within limit' do
        expect(user.can_add_content?(1000)).to eq(true)
      end

      it 'returns false when adding content exceeds limit' do
        # 100MB limit = 104_857_600 bytes
        excessive_bytes = 105_000_000
        expect(user.can_add_content?(excessive_bytes)).to eq(false)
      end
    end

    context 'for pro users' do
      it 'always returns true' do
        user = create(:user)
        create(:subscription, user: user, plan: :pro)
        
        expect(user.can_add_content?(1_000_000_000)).to eq(true)
      end
    end

    context 'for admin users' do
      it 'always returns true' do
        user = create(:user, :admin)
        
        expect(user.can_add_content?(1_000_000_000)).to eq(true)
      end
    end
  end

  describe '#admin?' do
    it 'returns true for admin users' do
      user = create(:user, :admin)
      expect(user.admin?).to eq(true)
    end

    it 'returns false for regular users' do
      user = create(:user)
      expect(user.admin?).to eq(false)
    end
  end
end
