module MetricCollector
  class Base
    attr_reader :name, :description, :supported_metrics

    def initialize(name, description, supported_metrics)
      @name = name
      @description = description
      @supported_metrics = supported_metrics
      @wanted_metrics = {}
      @processing = nil
    end

    def collect_metrics(code_directory, wanted_metrics); raise NotImplementedError; end

    protected

    def processing=(processing)
      @processing = processing
    end

    def wanted_metrics=(wanted_metric_configurations)
      @wanted_metrics = {}
      wanted_metric_configurations.each do |metric_configuration|
        if self.supported_metrics.keys.include?(metric_configuration.code)
          @wanted_metrics[metric_configuration.code] = metric_configuration
        end
      end
    end

    def wanted_metrics
      @wanted_metrics
    end

    def processing
      @processing
    end
  end
end