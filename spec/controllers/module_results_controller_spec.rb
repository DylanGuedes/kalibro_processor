require 'rails_helper'

describe ModuleResultsController do
  describe 'method' do
    describe 'get' do
      let(:module_result) { FactoryGirl.build(:module_result, id: 1) }

      context 'with valid ModuleResult instance' do
        before :each do
          ModuleResult.expects(:find).with(module_result.id.to_s).returns(module_result)

          post :get, id: module_result.id, format: :json
        end

        it { is_expected.to respond_with(:success) }

        it 'should return the module_result' do
          expect(JSON.parse(response.body)).to eq(JSON.parse(module_result.to_json))
        end
      end

      context 'with invalid ModuleResult instance' do
        let(:error_hash) { {error: 'RecordNotFound'} }

        before :each do
          ModuleResult.expects(:find).with(module_result.id.to_s).raises(ActiveRecord::RecordNotFound)

          post :get, id: module_result.id, format: :json
        end

        it { is_expected.to respond_with(:unprocessable_entity) }

        it 'should return the error_hash' do
          expect(JSON.parse(response.body)).to eq(JSON.parse(error_hash.to_json))
        end
      end
    end
  end
end
