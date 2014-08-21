module Processor
  class CompoundResultCalculator < ProcessingStep

    protected

    def self.task(runner)
      self.calculate_compound_results(runner.processing.root_module_result.pre_order, runner.compound_metrics)
    end

    def self.state
      "CALCULATING"
    end

    private

    def self.calculate_compound_results(pre_order_module_results, compound_metric_configurations)
      # The upper nodes of the tree need the children to be calculated first, so we reverse the pre_order
      pre_order_module_results.reverse_each do | module_result_child |
        #TODO: there might exist the need to check the scope before trying to calculate
        CompoundResults::Calculator.new(module_result_child, compound_metric_configurations).calculate
      end
    end
  end
end