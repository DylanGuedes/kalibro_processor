require 'rails_helper'
require 'metric_collector'

RSpec.describe MetricCollectorsController, :type => :controller do
  describe 'all_names' do
    context 'with an available collector' do
      let(:names) { ["Analizo"] }
      before :each do
        MetricCollector::Native::Analizo.expects(:available?).returns(true)
        get :all_names, format: :json
      end

      it { is_expected.to respond_with(:success) }

      it 'is expected to return the list of base tool names converted to JSON' do
        expect(JSON.parse(response.body)).to eq(JSON.parse({base_tool_names: names}.to_json))
      end
    end

    context 'with an unavailable collector' do
      let(:names) { [] }
      before :each do
        MetricCollector::Native::Analizo.expects(:available?).returns(false)
        get :all_names, format: :json
      end

      it { is_expected.to respond_with(:success) }

      it 'is expected to return the list of base tool names converted to JSON' do
        expect(JSON.parse(response.body)).to eq(JSON.parse({base_tool_names: names}.to_json))
      end
    end
  end

  describe 'find' do
    context 'with an available collector' do
      let!(:base_metric_collector) { FactoryGirl.build(:base_metric_collector) }
      before :each do
        MetricCollector::Native::Analizo.expects(:available?).returns(true)
        YAML.expects(:load_file).with("#{Rails.root}/config/collectors_descriptions.yml").returns({"analizo" => base_metric_collector.description})
        MetricCollector::Native::Analizo.any_instance.expects(:parse_supported_metrics).returns(base_metric_collector.supported_metrics)

        get :find, name: base_metric_collector.name, format: :json
      end

      it { is_expected.to respond_with(:success) }

      it 'should return the module_result' do
        expect(JSON.parse(response.body)).to eq(JSON.parse({base_tool: base_metric_collector}.to_json))
      end
    end

    context 'with an unavailable collector' do
      let(:base_tool_name) { "BaseTool" }
      let(:error_hash) { {error: Errors::NotFoundError.new("Base tool #{base_tool_name} not found.")} }

      before :each do
        MetricCollector::Native::Analizo.expects(:available?).returns(false)
        get :find, name: base_tool_name, format: :json
      end

      it { is_expected.to respond_with(:unprocessable_entity) }

      it 'is expected to return the error_hash' do
        expect(JSON.parse(response.body)).to eq(JSON.parse(error_hash.to_json))
      end
    end
  end
end