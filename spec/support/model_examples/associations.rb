shared_examples_for 'including an association in the api template' do
  describe 'which does not acts_as_api' do
    subject(:response) { @luke.as_api_response(:include_tasks) }

    it 'returns a hash' do
      expect(response).to be_kind_of(Hash)
    end

    it 'returns the correct number of fields' do
      expect(response).to have(1).keys
    end

    it 'returns all specified fields' do
      expect(response.keys).to include(:tasks)
    end

    it 'returns the correct values for the specified fields' do
      expect(response[:tasks]).to be_an Array
      expect(response[:tasks].size).to eq(3)
    end

    it 'should contain the associated sub models' do
      expect(response[:tasks]).to include(@destroy_deathstar, @study_with_yoda, @win_rebellion)
    end
  end

  describe 'which does acts_as_api' do
    context 'has_many' do
      before(:each) do
        Task.acts_as_api
        Task.api_accessible :include_tasks do |t|
          t.add :heading
          t.add :done
        end
      end

      subject(:response) { @luke.as_api_response(:include_tasks) }

      it 'returns a hash' do
        expect(response).to be_kind_of(Hash)
      end

      it 'returns the correct number of fields' do
        expect(response).to have(1).keys
      end

      it 'returns all specified fields' do
        expect(response.keys).to include(:tasks)
      end

      it 'returns the correct values for the specified fields' do
        expect(response[:tasks]).to be_an Array
        expect(response[:tasks].size).to eq(3)
      end

      it 'contains the associated child models with the determined api template' do
        response[:tasks].each do |task|
          expect(task.keys).to include(:heading, :done)
          expect(task.keys.size).to eq(2)
        end
      end

      it 'contains the correct data of the child models' do
        task_hash = [@destroy_deathstar, @study_with_yoda, @win_rebellion].collect { |t| { done: t.done, heading: t.heading } }
        expect(response[:tasks]).to eql task_hash
      end
    end

    context 'has_one' do
      before(:each) do
        Profile.acts_as_api
        Profile.api_accessible :include_profile do |t|
          t.add :avatar
          t.add :homepage
        end
      end

      subject(:response) { @luke.as_api_response(:include_profile) }

      it 'returns a hash' do
        expect(response).to be_kind_of(Hash)
      end

      it 'returns the correct number of fields' do
        expect(response).to have(1).keys
      end

      it 'returns all specified fields' do
        expect(response.keys).to include(:profile)
      end

      it 'returns the correct values for the specified fields' do
        expect(response[:profile]).to be_a Hash
        expect(response[:profile].size).to eq(2)
      end

      it 'contains the associated child models with the determined api template' do
        expect(response[:profile].keys).to include(:avatar, :homepage)
      end

      it 'contains the correct data of the child models' do
        profile_hash = { avatar: @luke.profile.avatar, homepage: @luke.profile.homepage }
        expect(response[:profile]).to eql profile_hash
      end
    end
  end

  describe 'which does acts_as_api, but with using another template name' do
    before(:each) do
      Task.acts_as_api
      Task.api_accessible :other_template do |t|
        t.add :description
        t.add :time_spent
      end
    end

    subject(:response) { @luke.as_api_response(:other_sub_template) }

    it 'returns a hash' do
      expect(response).to be_kind_of(Hash)
    end

    it 'returns the correct number of fields' do
      expect(response).to have(2).keys
    end

    it 'returns all specified fields' do
      expect(response.keys).to include(:first_name)
    end

    it 'returns the correct values for the specified fields' do
      expect(response.values).to include(@luke.first_name)
    end

    it 'returns all specified fields' do
      expect(response.keys).to include(:tasks)
    end

    it 'returns the correct values for the specified fields' do
      expect(response[:tasks]).to be_an Array
      expect(response[:tasks].size).to eq(3)
    end

    it 'contains the associated child models with the determined api template' do
      response[:tasks].each do |task|
        expect(task.keys).to include(:description, :time_spent)
        expect(task.keys.size).to eq(2)
      end
    end

    it 'contains the correct data of the child models' do
      task_hash = [@destroy_deathstar, @study_with_yoda, @win_rebellion].collect { |t| { description: t.description, time_spent: t.time_spent } }
      expect(response[:tasks]).to eql task_hash
    end
  end

  describe 'that is scoped' do
    before(:each) do
      # extend task model with scope
      Task.class_eval do
        scope :completed, -> { where(done: true) }
      end
      Task.acts_as_api
      Task.api_accessible :include_completed_tasks do |t|
        t.add :heading
        t.add :done
      end
    end

    subject(:response) { @luke.as_api_response(:include_completed_tasks) }

    it 'returns a hash' do
      expect(response).to be_kind_of(Hash)
    end

    it 'returns the correct number of fields' do
      expect(response.size).to eq(1)
    end

    it 'returns all specified fields' do
      expect(response.keys).to include(:completed_tasks)
    end

    it 'returns the correct values for the specified fields' do
      expect(response[:completed_tasks]).to be_an Array
      expect(response[:completed_tasks].size).to eq(2)
    end

    it 'contains the associated child models with the determined api template' do
      response[:completed_tasks].each do |task|
        expect(task.keys).to include(:heading, :done)
        expect(task.keys.size).to eq(2)
      end
    end

    it 'contains the correct data of the child models' do
      task_hash = [@destroy_deathstar, @study_with_yoda].collect { |t| { done: t.done, heading: t.heading } }
      expect(response[:completed_tasks]).to eql task_hash
    end
  end

  describe 'handling nil values' do
    context 'has_many' do
      before(:each) do
        Task.acts_as_api
        Task.api_accessible :include_tasks do |t|
          t.add :heading
          t.add :done
        end
      end

      subject(:response) { @han.as_api_response(:include_tasks) }

      it 'returns a hash' do
        expect(response).to be_kind_of(Hash)
      end

      it 'returns the correct number of fields' do
        expect(response).to have(1).keys
      end

      it 'returns all specified fields' do
        expect(response.keys).to include(:tasks)
      end

      it 'returns the correct values for the specified fields' do
        expect(response[:tasks]).to be_kind_of(Array)
      end

      it 'contains no associated child models' do
        expect(response[:tasks]).to have(0).items
      end
    end

    context 'has one' do
      before(:each) do
        Profile.acts_as_api
        Profile.api_accessible :include_profile do |t|
          t.add :avatar
          t.add :homepage
        end
      end

      subject(:response) { @han.as_api_response(:include_profile) }

      it 'returns a hash' do
        expect(response).to be_kind_of(Hash)
      end

      it 'returns the correct number of fields' do
        expect(response).to have(1).keys
      end

      it 'returns all specified fields' do
        expect(response.keys).to include(:profile)
      end

      it 'returns nil for the association' do
        expect(response[:profile]).to be_nil
      end
    end
  end
end
