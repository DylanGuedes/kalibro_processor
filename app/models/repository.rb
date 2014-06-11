class Repository < ActiveRecord::Base
  belongs_to :project

  validates :name, presence: true
  validates :name, uniqueness: { scope: :project_id ,
    message: "should be unique within project" }
  validates :address, presence: true
  validates :configuration_id, presence: true
  validates :project_id, presence: true

  belongs_to :project

  REPOSITORY_TYPES = [:BAZAAR, :CVS, :GIT, :LOCAL_DIRECTORY, :LOCAL_TARBALL,
  	:LOCAL_ZIP, :MERCURIAL, :REMOTE_TARBALL, :REMOTE_ZIP, :SUBVERSION]

  def self.supported_types
    REPOSITORY_TYPES.select {|type| Downloaders::Base.valid?(type) }
  end

  def configuration
    KalibroGatekeeperClient::Entities::Configuration.find(self.configuration_id)
  end

  def configuration=(conf)
    self.configuration_id = conf.id
  end

	def complete_name
		self.project.name + "-" + self.name
	end

  def process; raise NotImplementedError; end
end
