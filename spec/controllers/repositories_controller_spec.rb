require 'rails_helper'

RSpec.describe RepositoriesController, :type => :controller do
  let!(:repository) { FactoryGirl.build(:repository, id: 1) }

  describe 'show' do
    context 'when the Repository exists' do
      before :each do
        Repository.expects(:find).with(repository.id).returns(repository)

        get :show, id: repository.id, format: :json
      end

      it { is_expected.to respond_with(:success) }

      it 'is expected to return the list of repositories converted to JSON' do
        expect(JSON.parse(response.body)).to eq(JSON.parse({repository: repository}.to_json))
      end
    end

    context 'when the Repository exists' do
      before :each do
        Repository.expects(:find).with(repository.id).raises(ActiveRecord::RecordNotFound)

        get :show, id: repository.id, format: :json
      end

      it { is_expected.to respond_with(:unprocessable_entity) }

      it 'should return the error description' do
        expect(JSON.parse(response.body)).to eq(JSON.parse({error: 'RecordNotFound'}.to_json))
      end
    end
  end

  describe 'create' do
    let(:repository_params) { Hash[FactoryGirl.attributes_for(:repository, configuration_id: repository.configuration_id, project_id: repository.project_id).map { |k,v| [k.to_s, v.to_s] }] } #FIXME: Mocha is creating the expectations with strings, but FactoryGirl returns everything with sybols and integers
    context 'with valid attributes' do
      before :each do
        Repository.any_instance.expects(:save).returns(true)

        post :create, repository: repository_params, format: :json
      end

      it { is_expected.to respond_with(:created) }

      it 'is expected to return the repository' do
        repository.id = nil
        expect(JSON.parse(response.body)).to eq(JSON.parse({repository: repository}.to_json))
      end
    end

    context 'with invalid attributes' do
      before :each do
        Repository.any_instance.expects(:save).returns(false)

        post :create, repository: repository_params, format: :json
      end

      it { is_expected.to respond_with(:unprocessable_entity) }

      it 'should return the error description with the repository' do
        repository.id = nil
        expect(JSON.parse(response.body)).to eq(JSON.parse({repository: repository}.to_json))
      end
    end
  end

  describe 'update' do
    let!(:repository_params) { Hash[FactoryGirl.attributes_for(:repository, configuration_id: repository.configuration_id, project_id: repository.project_id).map { |k,v| [k.to_s, v.to_s] }] } #FIXME: Mocha is creating the expectations with strings, but FactoryGirl returns everything with sybols and integers

    before :each do
      Repository.expects(:find).with(repository.id).returns(repository)
    end

    context 'with valid attributes' do
      before :each do
        repository_params.delete('id')
        Repository.any_instance.expects(:update).with(repository_params).returns(true)

        put :update, repository: repository_params, id: repository.id, format: :json
      end

      it { is_expected.to respond_with(:created) }

      it 'is expected to return the repository' do
        expect(JSON.parse(response.body)).to eq(JSON.parse({repository: repository}.to_json))
      end
    end

    context 'with invalid attributes' do
      before :each do
        repository_params.delete('id')
        Repository.any_instance.expects(:update).with(repository_params).returns(false)

        put :update, repository: repository_params, id: repository.id, format: :json
      end

      it { is_expected.to respond_with(:unprocessable_entity) }

      it 'should return the error description with the repository' do
        expect(JSON.parse(response.body)).to eq(JSON.parse({repository: repository}.to_json))
      end
    end
  end

  describe 'destroy' do
    before :each do
      repository.expects(:destroy).returns(true)
      Repository.expects(:find).with(repository.id).returns(repository)

      delete :destroy, id: repository.id, format: :json
    end

    it { is_expected.to respond_with(:success) }
  end

  describe 'types' do
    let(:supported_types) { [:GIT, :SVN] }
    before :each do
      Repository.expects(:supported_types).returns(supported_types)

      get :types, format: :json
    end

    it { is_expected.to respond_with(:success) }

    it 'should return the supported types' do
      expect(JSON.parse(response.body)).to eq(JSON.parse({types: supported_types.map{|x| x.to_s}}.to_json))
    end
  end

  describe 'process' do
    context 'with a successful processing' do
      before :each do
        Repository.expects(:find).with(repository.id).returns(repository)
        repository.expects(:process).returns(true)

        get :process_repository, id: repository.id, format: :json
      end

      it { is_expected.to respond_with(:success) }
    end

    context 'with an unsuccessful processing' do
      before :each do
        Repository.expects(:find).with(repository.id).returns(repository)
        repository.expects(:process).raises(Errors::ProcessingError)

        get :process_repository, id: repository.id, format: :json
      end

      it { is_expected.to respond_with(:internal_server_error) }
    end
  end

  describe 'has_processing' do
    before :each do
      Repository.expects(:find).with(repository.id).returns(repository)
    end

    context 'with a repository with processings' do
      before :each do
        repository.expects(:processings).returns([FactoryGirl.build(:processing)])

        get :has_processing, id: repository.id, format: :json
      end

      it { is_expected.to respond_with(:success) }

      it 'should return true' do
        expect(JSON.parse(response.body)).to eq(JSON.parse({has_processing: true}.to_json))
      end
    end

    context 'with a repository without processings' do
      before :each do
        repository.expects(:processings).returns([])

        get :has_processing, id: repository.id, format: :json
      end

      it { is_expected.to respond_with(:success) }

      it 'should return false' do
        expect(JSON.parse(response.body)).to eq(JSON.parse({has_processing: false}.to_json))
      end
    end
  end

  describe 'has_processing_in_time' do
    let!(:processing) { FactoryGirl.build(:processing) }
    let!(:date) {"2011-10-20T18:26:43.151+00:00"}
    before :each do
      Repository.expects(:find).with(repository.id).returns(repository)
    end

    context 'with a processing' do
      context 'after a specific date' do
        before :each do
          repository.expects(:find_processing_by_date).with(date, ">=").returns([processing])

          get :has_processing_in_time, id: repository.id, date: date, after_or_before: "after", format: :json
        end

        it { is_expected.to respond_with(:success) }

        it 'should return true' do
          expect(JSON.parse(response.body)).to eq(JSON.parse({has_processing_in_time: true}.to_json))
        end
      end
      context 'before a specific date' do
        before :each do
          repository.expects(:find_processing_by_date).with(date, "<=").returns([processing])

          get :has_processing_in_time, id: repository.id, date: date, after_or_before: "before", format: :json
        end

        it { is_expected.to respond_with(:success) }

        it 'should return true' do
          expect(JSON.parse(response.body)).to eq(JSON.parse({has_processing_in_time: true}.to_json))
        end
      end
    end

    context 'without a processing' do
      context 'after a specific date' do
        before :each do
          repository.expects(:find_processing_by_date).with(date, ">=").returns([])

          get :has_processing_in_time, id: repository.id, date: date, after_or_before: "after", format: :json
        end

        it { is_expected.to respond_with(:success) }

        it 'should return false' do
          expect(JSON.parse(response.body)).to eq(JSON.parse({has_processing_in_time: false}.to_json))
        end
      end
      context 'before a specific date' do
        before :each do
          repository.expects(:find_processing_by_date).with(date, "<=").returns([])

          get :has_processing_in_time, id: repository.id, date: date, after_or_before: "before", format: :json
        end

        it { is_expected.to respond_with(:success) }

        it 'should return false' do
          expect(JSON.parse(response.body)).to eq(JSON.parse({has_processing_in_time: false}.to_json))
        end
      end
    end
  end

  describe 'has_ready_processing' do
    before :each do
      Repository.expects(:find).with(repository.id).returns(repository)
    end
    context 'with a ready processing' do
      before :each do
        repository.expects(:find_ready_processing).returns([FactoryGirl.build(:processing)])

        get :has_ready_processing, id: repository.id, format: :json
      end

      it { is_expected.to respond_with(:success) }

      it 'should return true' do
        expect(JSON.parse(response.body)).to eq(JSON.parse({has_ready_processing: true}.to_json))
      end
    end
    context 'without a ready processing' do
      before :each do
        repository.expects(:find_ready_processing).returns([])

        get :has_ready_processing, id: repository.id, format: :json
      end

      it { is_expected.to respond_with(:success) }

      it 'should return false' do
        expect(JSON.parse(response.body)).to eq(JSON.parse({has_ready_processing: false}.to_json))
      end
    end
  end

  describe 'last_ready_processing' do
    let!(:processing) { FactoryGirl.build(:processing) }
    before :each do
      Repository.expects(:find).with(repository.id).returns(repository)
    end
    context 'with a ready processing' do
      before :each do
        repository.expects(:find_ready_processing).returns([processing])

        get :last_ready_processing, id: repository.id, format: :json
      end

      it { is_expected.to respond_with(:success) }

      it 'should return true' do
        expect(JSON.parse(response.body)).to eq(JSON.parse({last_ready_processing: processing}.to_json))
      end
    end
    context 'without a ready processing' do
      before :each do
        repository.expects(:find_ready_processing).returns([])

        get :last_ready_processing, id: repository.id, format: :json
      end

      it { is_expected.to respond_with(:success) }

      it 'should return false' do
        expect(JSON.parse(response.body)).to eq(JSON.parse({last_ready_processing: nil}.to_json))
      end
    end
  end

  describe 'first_processing_in_time' do
    let!(:processing) { FactoryGirl.build(:processing) }
    before :each do
      Repository.expects(:find).with(repository.id).returns(repository)
    end
    context 'without a date' do
      before :each do
        repository.expects(:processings).returns([processing])

        get :first_processing_in_time, id: repository.id, format: :json
      end

      it { is_expected.to respond_with(:success) }

      it 'should return false' do
        expect(JSON.parse(response.body)).to eq(JSON.parse({processing: processing}.to_json))
      end
    end

    context 'with a date' do
      let!(:date) {"2011-10-20T18:26:43.151+00:00"}
      before :each do
        repository.expects(:find_processing_by_date).with(date, ">=").returns([processing])

        get :first_processing_in_time, id: repository.id, after_or_before: "after", date: date, format: :json
      end

      it { is_expected.to respond_with(:success) }

      it 'should return false' do
        expect(JSON.parse(response.body)).to eq(JSON.parse({processing: processing}.to_json))
      end
    end
  end

  describe 'last_processing_in_time' do
    let!(:processing) { FactoryGirl.build(:processing) }
    before :each do
      Repository.expects(:find).with(repository.id).returns(repository)
    end
    context 'without a date' do
      before :each do
        repository.expects(:processings).returns([processing])

        get :last_processing_in_time, id: repository.id, format: :json
      end

      it { is_expected.to respond_with(:success) }

      it 'should return false' do
        expect(JSON.parse(response.body)).to eq(JSON.parse({processing: processing}.to_json))
      end
    end

    context 'with a date' do
      let!(:date) {"2011-10-20T18:26:43.151+00:00"}
      before :each do
        repository.expects(:find_processing_by_date).with(date, "<=").returns([processing])

        get :last_processing_in_time, id: repository.id, after_or_before: "before", date: date, format: :json
      end

      it { is_expected.to respond_with(:success) }

      it 'should return false' do
        expect(JSON.parse(response.body)).to eq(JSON.parse({processing: processing}.to_json))
      end
    end
  end

  describe 'last_processing_state' do
    let!(:processing) { FactoryGirl.build(:processing) }
    before :each do
      repository.expects(:processings).returns([processing])
      Repository.expects(:find).with(repository.id).returns(repository)

      get :last_processing_state, id: repository.id, format: :json
    end

    it 'is expected to return the processing state' do
      expect(JSON.parse(response.body)).to eq(JSON.parse({processing_state: processing.state}.to_json))
    end
  end
end
