class MetricResult < BaseMetricResult
  def range
    ranges = KalibroClient::Entities::Configurations::KalibroRange.ranges_of(metric_configuration.id)
    ranges.detect { |range| range.range === self.value }
  end

  def has_grade?
    range = self.range
    !range.nil? && !range.reading.nil?
  end

  def grade; self.range.grade; end

  def descendant_values
    module_result.children.map { |child| child.metric_result_for(self.metric).value }
  end
end
