require 'rails_helper'

describe ModuleResult, :type => :model do
  describe 'associations' do
    it { is_expected.to have_one(:kalibro_module).dependent(:destroy) }
    it { is_expected.to have_many(:metric_results).dependent(:destroy) }
    it { is_expected.to belong_to(:processing) }

    # Usually we do not touch the database on unit tests. But this is kind of a intricated self-relationship so it's worth the cost.
    context 'with children and parent associations' do
      let(:parent_module_result) { FactoryGirl.create(:module_result) }
      let(:child_module_result) { FactoryGirl.create(:module_result, parent: parent_module_result) }

      describe 'children' do
        it 'the parent should return the children' do
          expect(parent_module_result.children).to eq([child_module_result])
        end

        it 'should add a child' do
          another_child = FactoryGirl.create(:module_result)
          parent_module_result.children << another_child
          parent_module_result.save

          expect(parent_module_result.children).to eq([child_module_result, another_child])
        end
      end

      describe 'parent' do
        it 'should return the child' do
          expect(child_module_result.parent).to eq(parent_module_result)
        end

        it 'should set the parent' do
          another_parent = FactoryGirl.create(:module_result)
          child_module_result.parent = another_parent
          child_module_result.save

          expect(child_module_result.parent).to eq(another_parent)
        end
      end
    end
  end

  describe 'method' do
    describe 'metric_result_for' do
      subject { FactoryGirl.build(:module_result) }

      let(:metric_result) {subject.metric_results.first}

      before :each do
        subject.expects(:reload)
      end

      context 'when a module result has the specific metric' do
        let(:metric) { subject.metric_results.first.metric }
        it 'should return the metric_result' do
          expect(subject.metric_result_for(metric)).to eq(metric_result)
        end
      end

      context 'when a module result has not the specific metric' do
        let(:another_metric) { FactoryGirl.build(:analizo_native_metric) }
        it 'should return the metric_result' do
          expect(subject.metric_result_for(another_metric)).to be_nil
        end
      end
    end

    describe 'find_by_module_and_processing' do
      let!(:kalibro_module) { FactoryGirl.build(:kalibro_module) }
      let!(:processing) { FactoryGirl.build(:processing) }
      let!(:module_result) { FactoryGirl.build(:module_result) }

      before :each do
        name_filtered_results = Object.new
        name_filtered_results.expects(:where).
          with("kalibro_modules.granlrty" => kalibro_module.granularity.to_s).
          returns([module_result])

        processing_filtered_results = Object.new
        processing_filtered_results.expects(:where).
          with("kalibro_modules.long_name" => kalibro_module.long_name).
          returns(name_filtered_results)

        join_result = Object.new
        join_result.expects(:where).with(processing: processing).at_least_once.returns(processing_filtered_results)
        ModuleResult.expects(:joins).at_least_once.with(:kalibro_module).returns(join_result)
      end

      it 'is expected to return the module_result' do
        expect(ModuleResult.find_by_module_and_processing(kalibro_module, processing)).to eq(module_result)
      end
    end

    describe 'to_json' do
      subject { FactoryGirl.build(:module_result) }

      it 'is expected to add the kalibro_module to the JSON' do
        expect(JSON.parse(subject.to_json)['kalibro_module']).to eq(JSON.parse(subject.kalibro_module.to_json))
      end

      it 'is expected to preserve all the attributes' do
        expect(JSON.parse(subject.to_json)['parent']).to eq(JSON.parse(subject.to_json)['parent'])
        expect(JSON.parse(subject.to_json)['grade']).to eq(JSON.parse(subject.to_json)['grade'])
        expect(JSON.parse(subject.to_json)['height']).to eq(JSON.parse(subject.to_json)['height'])
      end
    end

    describe 'pre_order' do
      context 'when it does not have children' do
        before :each do
          subject.expects(:children).returns([])
        end
        it 'is expected to return an array with only itself' do
          expect(subject.pre_order).to eq([subject])
        end
      end

      context 'when it does have children' do
        let!(:child_1) { FactoryGirl.build(:module_result, id: 1) }
        let!(:child_2) { FactoryGirl.build(:module_result, id: 2) }
        let!(:grandchild_1) { FactoryGirl.build(:module_result, id: 3) }
        let!(:grandchild_2) { FactoryGirl.build(:module_result, id: 4) }
        let!(:grandchild_3) { FactoryGirl.build(:module_result, id: 5) }
        let!(:grandchild_4) { FactoryGirl.build(:module_result, id: 6) }

        before :each do
          subject.expects(:children).returns([child_1, child_2])
          child_1.expects(:children).returns([grandchild_1, grandchild_2])
          child_2.expects(:children).returns([grandchild_3, grandchild_4])
          grandchild_1.expects(:children).returns([])
          grandchild_2.expects(:children).returns([])
          grandchild_3.expects(:children).returns([])
          grandchild_4.expects(:children).returns([])
        end
        it 'is expected to return an array with the pre order tree traversal' do
          expect(subject.pre_order).to eq([subject, child_1, grandchild_1, grandchild_2, child_2, grandchild_3, grandchild_4])
        end
      end

      context 'when it is not the root module result' do
        let!(:root) { FactoryGirl.build(:module_result, id: 1)}
        let!(:child) { FactoryGirl.build(:module_result, id: 2)}
        before :each do
          child.expects(:parent).twice.returns(root)
          root.expects(:parent).returns(nil)
          root.expects(:children).returns([child])
        end
        it 'is expected to return the complete pre order tree traversal (from root)' do
          expect(child.pre_order).to eq([root, child])
        end
      end
    end
  end
end
