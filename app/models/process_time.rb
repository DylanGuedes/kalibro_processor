class ProcessTime < ActiveRecord::Base
  belongs_to :processing
  validates :state, presence: true
  attr_accessor :time

  def time
    unless self.created_at.nil?
      self.updated_at - self.created_at
    else
      nil
    end
  end

  # Adding time
  def to_json(options={})
    json = super(options)
    hash = JSON.parse(json)
    hash["time"] = self.time
    hash.to_json
  end
end
