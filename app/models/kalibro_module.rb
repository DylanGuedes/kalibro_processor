require 'validators/kalibro_module_long_name_validator'

class KalibroModule < ActiveRecord::Base
  belongs_to :module_result # one for each MetricCollector
  validates :module_result, presence: true
  validates_with KalibroModuleLongNameValidator, unless: 'self.module_result.nil?'

  def name=(value)
    self.long_name = value
    self.long_name = value.join('.') if value.is_a?(Array)
  end

  def name
    self.long_name.split('.')
  end

  def short_name
    name.last
  end

  def parent
    if self.granularity.type == KalibroClient::Entities::Miscellaneous::Granularity::SOFTWARE
      return nil
    elsif self.name.length <= 1
      find_or_instantiate(["ROOT"], KalibroClient::Entities::Miscellaneous::Granularity.new(KalibroClient::Entities::Miscellaneous::Granularity::SOFTWARE))
    else
      new_granularity = self.granularity.parent
      new_granularity = KalibroClient::Entities::Miscellaneous::Granularity::PACKAGE if new_granularity.type == KalibroClient::Entities::Miscellaneous::Granularity::SOFTWARE # if the parent is not the ROOT, so, it should be a PACKAGE not a SOFTWARE
      find_or_instantiate(self.name[0..-2], new_granularity)
    end
  end

  def granularity=(value)
    super(value.to_s)
  end

  def granularity
    KalibroClient::Entities::Miscellaneous::Granularity.new(super.to_sym)
  end

  def to_s
    self.short_name
  end

  private

  def find_or_instantiate(name, granularity)
    found_modules = KalibroModule.where(long_name: name.join('.'), granularity: granularity.to_s)

    unless found_modules.empty?
      found_modules.first
    else
      KalibroModule.new(name: name, granularity: granularity)
    end
  end
end
