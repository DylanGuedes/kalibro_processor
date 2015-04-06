module MetricCollector
  module Native
    module MetricFu
      class Collector < MetricCollector::Base
        def initialize
          description = "" #FIXME: YAML.load_file("#{Rails.root}/config/collectors_descriptions.yml")["metric_fu"]
          super("MetricFu", description, {}) #FIXME: the last attribute should be a call to `parse_supported_metrics`
        end

        def collect_metrics(code_directory, wanted_metric_configurations)
          runner = Runner.new(repository_path: code_directory)

          runner.run
          MetricCollector::Native::MetricFu::Parser.parse_wanted(runner.yaml_path, wanted_metric_configurations)
          runner.clean_output
        end

        private

        #FIXME: def parse_supported_metrics; end
      end
    end
  end
end