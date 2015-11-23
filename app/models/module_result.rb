class ModuleResult < ActiveRecord::Base
  has_one :kalibro_module, dependent: :destroy #It can go wrong if someday we want to destroy only module results and not the whole processing
  has_many :children, foreign_key: 'parent_id', class_name: 'ModuleResult', dependent: :destroy
  has_many :tree_metric_results, dependent: :destroy
  has_many :hotspot_metric_results, dependent: :destroy

  belongs_to :parent, class_name: 'ModuleResult'
  belongs_to :processing

  attr_reader :pre_order

  def self.find_by_module_and_processing(kalibro_module, processing)
    ModuleResult.joins(:kalibro_module).
      where(processing: processing).
      where("kalibro_modules.long_name" => kalibro_module.long_name).
      where("kalibro_modules.granularity" => kalibro_module.granularity.to_s).first
  end

  def metric_result_for(metric)
    self.reload # reloads to get recently created TreeMetricResults
    self.tree_metric_results.each {|metric_result| return metric_result if metric_result.metric == metric}
    return nil
  end

  # Adding kalibro_module to the result
  def to_json(options={})
    json = super(options)
    hash = JSON.parse(json)
    hash["kalibro_module"] = kalibro_module
    hash.to_json
  end

  def pre_order
    root = self
    root = root.parent until root.parent.nil?
    @pre_order ||= pre_order_traverse(root).to_a
  end

  def descendants
    @descendants ||= pre_order_traverse(self).to_a
  end

  def descendant_hotspot_metric_results
    HotspotMetricResult.where(module_result_id: descendants.map(&:id))
  end

  def metric_results
    warn('DEPRECATED: `ModuleResult#metric_results` has been renamed to `ModuleResult#tree_metric_results`')
    self.tree_metric_results
  end

  def metric_results=(value)
    warn('DEPRECATED: `ModuleResult#metric_results=` has been renamed to `ModuleResult#tree_metric_results=`')
    self.tree_metric_results = value
  end

  protected

  def pre_order_traverse(module_result, &block)
    if block_given?
      yield module_result
      module_result.children.each { |child| pre_order_traverse(child, &block) }
    else
      Enumerator.new do |yielder|
        pre_order_traverse(module_result) { |descendant| yielder << descendant }
      end
    end
  end
end
