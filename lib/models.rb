class Entry
  include DataMapper::Resource

  property :id, Integer, :serial => true
  property :slug, String, :size => 255, :nullable => false, :index => :unique
  property :title, String, :size => 255, :nullable => false
end

class Post
  include DataMapper::Resource
  include Paperclip::Resource

  property :id, Integer, :serial => true
  property :slug, String, :size => 255, :nullable => false, :index => :unique
  property :title, String, :size => 255, :nullable => false
  property :summary, Text, :lazy => false
  property :event, Boolean, :default => false, :index => true
  property :created_at, DateTime, :nullable => false, :index => true
  property :updated_at, DateTime, :nullable => false
  property :body, Text

  property :flyer_file_name, String
  property :flyer_content_type, String
  property :flyer_file_size, Integer
  property :flyer_updated_at, DateTime

  has_attached_file :flyer

  alias_method :event, :event?

  before(:save) do
    self.updated_at = Time.now
    self.make_summary!
    self.make_slug!
  end

  def initialize(attributes={})
    self.created_at = Time.now
    self.updated_at = self.created_at
    super
  end

  def url
    d = created_at
    "post/#{d.year}/#{d.month}/#{d.day}/#{slug}"
  end

  def permalink
  end

  def make_slug!
    slug = self.title.downcase.gsub(/ /, '_').gsub(/[^a-z0-9_]/, '').squeeze('_')
    self.slug = self.class.first(:slug => slug) ? slug + "_#{Time.now.strftime("%Y-%d")}" : slug
  end

  def make_summary!
    unless self.summary
      word_count = body.split(/\s/).size
      self.summary = word_count <= 50 ? self.body : self.body[0..50]
    end
  end

  ### fetching

  def self.latest(options={})
    all({ :order => [:created_at.desc], :limit => 20 }.merge(options))
  end

  def self.news(options={})
    all({ :order => [:created_at.desc], :limit => 20, :event => false }.merge(options))
  end
  def self.events(options={})
    all({ :order => [:created_at.desc], :limit => 20, :event => true }.merge(options))
  end
end

class GreekClass
  include DataMapper::Resource
  include Paperclip::Resource

  property :name, String, :size => 255, :nullable => false
  property :short, String, :size => 10, :nullable => false, :index => :unique

  property :banner_file_name, String
  property :banner_content_type, String
  property :banner_file_size, Integer

  has_attached_file :banner
end

class Brother
  include DataMapper::Resource
  include Paperclip::Resource

  property :id, Integer, :serial => true
  property :pledge_class_id, Integer, :index => true, :nullable => false
  property :name, String, :size => 255, :nullable => false
  property :pledge_name, String, :size => 255, :nullable => false
  property :hometown, String, :size => 255
  property :major, String, :size => 255
  property :interests, String, :size => 255
  property :quote, String

  property :mugshot_file_name, String
  property :mugshot_content_type, String
  property :mugshot_file_size, Integer

  has_attached_file :mugshot

  belongs_to :greek_class
end
