require 'rails_helper'

describe Processor::TreeBuilder do
  describe 'methods' do
    let!(:configuration) { FactoryGirl.build(:configuration) }
    let!(:repository) { FactoryGirl.build(:repository, scm_type: "GIT", configuration: configuration) }
    let!(:processing) { FactoryGirl.build(:processing, repository: repository) }
    let!(:root_module_result) { FactoryGirl.build(:module_result) }
    let!(:module_result) { FactoryGirl.build(:module_result_class_granularity) }

    describe 'build_tree' do
      context 'when there are module results' do
        before :each do
          filtered_module_results = Object.new
          module_result_limits = Object.new
          module_result.expects(:update).with(parent: root_module_result).returns(true)
          module_result_limits.expects(:offset).with(0).returns([module_result, root_module_result])
          module_result_limits.expects(:offset).with(100).returns([])
          filtered_module_results.expects(:limit).at_least_once.with(100).returns(module_result_limits)
          ModuleResult.expects(:where).with(processing: processing).at_least_once.returns(filtered_module_results)
          module_result.kalibro_module.expects(:parent).returns(root_module_result.kalibro_module)
          ModuleResult.expects(:find_by_module_and_processing).at_least_once.returns(nil)
          root_module_result.kalibro_module.expects(:parent).twice.returns(nil)
          ModuleResult.expects(:create).with(kalibro_module: root_module_result.kalibro_module, processing: processing).returns(root_module_result)
          processing.expects(:update).twice.with(root_module_result: root_module_result).returns(true)
        end

        it 'is expected to build the module results tree' do
          Processor::TreeBuilder.build_tree(processing)
        end
      end
    end
  end
end