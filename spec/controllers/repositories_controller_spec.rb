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
end