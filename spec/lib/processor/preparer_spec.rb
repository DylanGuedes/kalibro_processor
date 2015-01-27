require 'rails_helper'
require 'processor'

describe Processor::Preparer do
  describe 'methods' do
    let!(:code_dir) { "/tmp/test" }
    let!(:configuration) { FactoryGirl.build(:configuration) }
    let!(:repository) { FactoryGirl.build(:repository, scm_type: "GIT", configuration: configuration) }
    let!(:processing) { FactoryGirl.build(:processing, repository: repository) }
    let!(:context) { FactoryGirl.build(:context, repository: repository, processing: processing) }
    let!(:metric_configuration) { FactoryGirl.build(:metric_configuration) }
    let!(:compound_metric_configuration) { FactoryGirl.build(:compound_metric_configuration) }
    let!(:dir) { YAML.load_file("#{Rails.root}/config/repositories.yml")["repositories"]["path"] }

    describe 'task' do
      context 'when the base directory exists' do
        before :each do
          repository.expects(:update).with(code_directory: code_dir)
          # FIXME: the factory should do it instead of calling the client.
          repository.expects(:configuration).returns(configuration)
          Dir.expects(:exists?).with(dir).at_least_once.returns(true)
          Digest::MD5.expects(:hexdigest).returns("test")
          Dir.expects(:exists?).with(code_dir).returns(false)
          KalibroClient::Configurations::MetricConfiguration.expects(:metric_configurations_of).
            with(configuration.id).returns([metric_configuration, compound_metric_configuration])
        end

        it 'is expected to accomplish the preparing state of a process successfully' do
          Processor::Preparer.task(context)
        end
      end

      context 'when the base directory does not exist' do
        before :each do
          Dir.expects(:exists?).with(dir).returns(false)
        end

        it 'is expected to raise a RunTimeError exception' do
          expect { Processor::Preparer.task(context) }.to raise_error(Errors::ProcessingError, "Repository's directory (#{dir}) does not exist")
        end
      end
    end

    describe 'state' do
      it 'is expected to return "PREPARING"' do
        expect(Processor::Preparer.state).to eq("PREPARING")
      end
    end
  end
end
