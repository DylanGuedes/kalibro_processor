require 'metric_collector/native/radon'

module MetricCollector
  # Once all collectors are under Kolekti's structure, this module will be dropped in favour of KolektiAdapter
  module Native
    ALL = {}

    def self.available
      ALL.select {|name, collector| collector.available?}
    end

    def self.details
      # This cache will represent a HUGE improvement for MetricCollectorsController response times
      Rails.cache.fetch("metric_collector/details", expires_in: 1.day) do
        @details = []

        available.each do |name, collector|
          collector_instance = collector.new
          @details << MetricCollector::Details.new(name: name,
                                                   description: collector_instance.details.description,
                                                   supported_metrics: collector_instance.details.supported_metrics)
        end
      end

      return @details
    end
  end
end
