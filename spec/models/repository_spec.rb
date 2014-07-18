require 'rails_helper'

describe Repository, :type => :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:address) }
    it { is_expected.to validate_presence_of(:configuration_id) }
    it { is_expected.to validate_presence_of(:project_id) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:project_id).with_message(/should be unique within project/) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:project)}
    it { is_expected.to have_many(:processings)}
  end

  describe 'methods' do
    describe 'supported_types' do
      before :each do
        Downloaders::GitDownloader.expects(:available?).at_least_once.returns(true)
        Downloaders::SvnDownloader.expects(:available?).at_least_once.returns(true)
      end

      it 'should add available repository types to supported_types and return them' do
        expect(Repository.supported_types).to include("GIT")
        expect(Repository.supported_types).to include("SVN")
      end
    end

    describe 'configuration' do
      subject { FactoryGirl.build(:repository) }

      it 'should call the Gatekeeper Configuration' do
        KalibroGatekeeperClient::Entities::Configuration.expects(:find).twice.with(subject.configuration_id).returns(subject.configuration)
        subject.configuration
      end
    end

    describe 'configuration=' do
      subject { FactoryGirl.build(:repository) }
      let(:configuration) { FactoryGirl.build(:another_configuration) }

      it 'should call the Gatekeeper Configuration' do
        subject.configuration = configuration
        expect(subject.configuration_id).to eq(configuration.id)
      end
    end

    describe 'process' do
      it 'is expected to process a repository' do
        Runner.any_instance.expects(:run)
        subject.process
      end
    end

    describe 'history_of' do
      let!(:kalibro_module) { FactoryGirl.build(:kalibro_module) }
      let!(:module_result) { FactoryGirl.build(:module_result) }
      let!(:processing) { FactoryGirl.build(:processing) }
      before :each do
        subject.expects(:processings).returns([processing, processing])
        processing.expects(:module_results).twice.returns([module_result])
        module_result.expects(:kalibro_module).twice.returns(kalibro_module)
      end

      context 'when the module result exists' do
        let(:response) { [[processing.updated_at, module_result], [processing.updated_at, module_result]] }
        it 'is expected to return a list of all module_results associated with the time when it was last updated' do
          expect(subject.history_of(kalibro_module.long_name)).to eq(response)
        end
      end

      context 'when the module result does not exist' do
        it 'is expected to return an empty list' do
          expect(subject.history_of("kalibro_module.long_name")).to eq([])
        end
      end
    end
  end
end