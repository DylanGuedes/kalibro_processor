require 'rails_helper'

describe MetricResult, :type => :model do

  describe 'associations' do
    it { is_expected.to belong_to(:module_result) }
  end

  describe 'method' do
    let!(:metric_configuration) { FactoryGirl.build(:metric_configuration) }

    describe 'range' do
      subject { FactoryGirl.build(:metric_result_with_value, module_result: FactoryGirl.build(:module_result)) }

      context 'with finite ranges' do
        let!(:range) { FactoryGirl.build(:range) }
        let!(:yet_another_range) { FactoryGirl.build(:yet_another_range) }

        before :each do
          KalibroClient::Entities::Configurations::MetricConfiguration.expects(:find).
            returns(metric_configuration)
          KalibroClient::Entities::Configurations::KalibroRange.expects(:ranges_of).
            with(subject.metric_configuration.id).returns([range, yet_another_range])
        end

        it 'should return the range that contains the aggregated value of the metric result' do
          expect(subject.range).to eq(range)
        end

        after :each do
          Rails.cache.clear # This test depends on metric configuration
        end
      end

      context 'with infinite range' do
        let!(:infinite_range) { FactoryGirl.build(:range, :infinite) }

        before :each do
          KalibroClient::Entities::Configurations::MetricConfiguration.expects(:find).
            returns(metric_configuration)
          KalibroClient::Entities::Configurations::KalibroRange.expects(:ranges_of).
            with(subject.metric_configuration.id).returns([infinite_range])
        end

        it 'should return the range that contains the aggregated value of the metric result' do
          pending "We should handle conversions from string to Float on KalibroClient"
          expect(subject.range).to eq(infinite_range)
        end

        after :each do
          Rails.cache.clear # This test depends on metric configuration
        end
      end
    end

    describe 'has_grade?' do
      subject { FactoryGirl.build(:metric_result) }

      context 'without a range' do
        before :each do
          subject.expects(:range).returns(nil)
        end

        it 'should return false' do
          expect(subject.has_grade?).to be_falsey
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
            expect(subject.has_grade?).to be_falsey
          end
        end

        context 'with a reading' do
          before :each do
            range.expects(:reading).returns(FactoryGirl.build(:reading))
          end

          it 'should return true' do
            expect(subject.has_grade?).to be_truthy
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
        module_result.expects(:metric_result_for).at_least_once.
          with(subject.metric).returns(son)
      end

      it "should return an array with all its children's values" do
        expect(subject.descendant_values).to eq([2.0, 2.0])
      end

      it "should be a float values array" do
        expect(subject.descendant_values).to be_a(Array)
      end
    end

    describe 'metric' do
      subject { FactoryGirl.build(:metric_result, metric: nil, module_result: FactoryGirl.build(:module_result)) }

      before :each do
        KalibroClient::Entities::Configurations::MetricConfiguration.expects(:find).
          with(subject.metric_configuration_id).
          returns(metric_configuration)
      end

      it 'is expected to be a KalibroClient::Entities::Miscellaneous::Metric' do
        expect(subject.metric).to be_a(KalibroClient::Entities::Miscellaneous::Metric)
      end

      after :each do
        Rails.cache.clear # This test depends on metric configuration
      end
    end
  end
end
