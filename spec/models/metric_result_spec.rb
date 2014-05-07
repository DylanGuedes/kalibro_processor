require 'spec_helper'

describe MetricResult do
  describe 'associations' do
    before :each do
      KalibroGatekeeperClient::Entities::MetricConfiguration.expects(:find).returns(FactoryGirl.build(:metric_configuration))
    end

    it { should belong_to(:module_result) }
  end

  describe 'method' do
    let!(:metric_configuration) { FactoryGirl.build(:metric_configuration) }
    before :each do
        KalibroGatekeeperClient::Entities::MetricConfiguration.expects(:find).
          at_least_once.returns(metric_configuration)
    end

    describe "initialize" do
      context "with valid attributes" do
        subject { FactoryGirl.build(:metric_result_with_value) }

        it 'should return an instance of MetricResult' do
          subject.should be_a(MetricResult)
        end

        it 'should have a metric' do
          subject.metric.should eq(metric_configuration.metric)
        end
      end
    end

    describe 'aggregated_value' do
      let!(:stats) { DescriptiveStatistics::Stats.new([1, 2, 3]) }

      before :each do
        subject.expects(:descendant_values).at_least_once.returns(stats)
      end

      context 'when value is nil and the values array is not empty' do
        subject { FactoryGirl.build(:metric_result) }

        it 'should calculate the mean value of the values array' do
          subject.aggregated_value.should eq(2.0)
        end
      end

      context 'when the metric_results are not from a leaf module' do
        subject { FactoryGirl.build(:metric_result_with_value) }

        it 'should return the value' do
          subject.aggregated_value.should eq(subject.value)
        end
      end
    end

    describe 'range' do
      let!(:range) { FactoryGirl.build(:range) }
      let!(:yet_another_range) { FactoryGirl.build(:yet_another_range) }
      subject { FactoryGirl.build(:metric_result_with_value) }

      before :each do
        KalibroGatekeeperClient::Entities::Range.expects(:ranges_of).
            with(subject.metric_configuration.id).returns([range, yet_another_range])
        subject.expects(:aggregated_value).returns(subject.value)
      end

      it 'should return the range that contains the aggregated value of the metric result' do
        subject.range.should eq(range)
      end
    end

    describe 'has_grade?' do
      subject { FactoryGirl.build(:metric_result) }

      context 'without a range' do
        before :each do
          subject.expects(:range).returns(nil)
        end

        it 'should return false' do
          subject.has_grade?.should be_false
        end
      end

      context 'with a range' do
        let!(:range) { FactoryGirl.build(:range) }

        before :each do
          subject.expects(:range).at_least_once.returns(range)
        end

        context 'without a reading' do
          before :each do
            range.expects(:reading).returns(nil)
          end

          it 'should return false' do
            subject.has_grade?.should be_false
          end
        end

        context 'with a reading' do
          before :each do
            range.expects(:reading).returns(FactoryGirl.build(:reading))
          end

          it 'should return true' do
            subject.has_grade?.should be_true
          end
        end
      end
    end

    describe 'grade' do
      subject { FactoryGirl.build(:metric_result) }

      it "should call range's grade" do
        range = FactoryGirl.build(:range)
        range.expects(:grade).returns(10.0)
        subject.expects(:range).returns(range)

        subject.grade
      end
    end

    describe 'descendant_values' do
      subject { FactoryGirl.build(:metric_result) }
      let(:son) { FactoryGirl.build(:metric_result_with_value) }
      let!(:module_result) { FactoryGirl.build(:module_result) }

      before :each do
        subject.expects(:module_result).returns(module_result)
        module_result.expects(:children).returns([module_result, module_result])
        module_result.expects(:metric_results_for).at_least_once.
          with(subject.metric).returns(son)
      end

      it "should return an array with all its children's values" do
        subject.descendant_values.should eq([2.0, 2.0])
      end

      it "should be a DescriptiveStatistics array" do
        subject.descendant_values.should be_a(DescriptiveStatistics::Stats)
      end
    end
  end
end
