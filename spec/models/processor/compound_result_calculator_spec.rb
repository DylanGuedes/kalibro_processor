require 'rails_helper'

describe Processor::CompoundResultCalculator do
  describe 'methods' do
    describe 'calculate_compound_results' do
      let(:configuration) { FactoryGirl.build(:configuration) }
      let!(:code_dir) { "/tmp/test" }
      let!(:repository) { FactoryGirl.build(:repository, scm_type: "GIT", configuration: configuration, code_directory: code_dir) }
      let!(:root_module_result) { FactoryGirl.build(:module_result) }
      let!(:processing) { FactoryGirl.build(:processing, repository: repository, root_module_result: root_module_result) }
      let!(:module_result) { FactoryGirl.build(:module_result_class_granularity, parent: root_module_result) }
      let!(:compound_metric_configurations) { [FactoryGirl.build(:compound_metric_configuration)] }
      let!(:runner) { Runner.new(repository, processing) }

      before :each do
        runner.compound_metrics = compound_metric_configurations
      end

      context 'when the module result tree has been well-built' do

        before :each do
          root_module_result.expects(:children).twice.returns([module_result])
          CompoundResults::Calculator.any_instance.expects(:calculate).twice #One for each module_result
        end

        it 'is expected to calculate the compound results' do
          Processor::CompoundResultCalculator.task(runner)
        end
      end
    end

    describe 'state' do
      it 'is expected to return "CALCULATING"' do
        expect(Processor::CompoundResultCalculator.state).to eq("CALCULATING")
      end
    end
  end
end