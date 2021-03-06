require 'dm-core'
require 'dm-validations'
require 'dm-paperclip'
require 'rdiscount'

class Page
  include DataMapper::Resource

  property :id, Integer, :serial => true
  property :slug, String, :size => 255, :nullable => false, :index => :unique
  property :created_at, DateTime, :nullable => false, :index => true
  property :updated_at, DateTime, :nullable => false

  property :title, String, :size => 255, :nullable => false
  property :body, Text, :lazy => false

  validates_present :title, :body, :slug
  validates_is_unique :slug

  before(:save) do
    self.updated_at = Time.now
  end

  def initialize(attributes={})
    self.created_at = Time.now
    self.updated_at = self.created_at
    self.slug = attributes[:title].downcase
    super
  end

  def body_html
    RDiscount.new(self.body, :smart).to_html.strip
  end

  def url
    "#{self.slug}"
  end
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

  validates_present :title, :body, :summary, :slug
  validates_is_unique :slug

  has_attached_file :flyer

  alias_method :event, :event?

  before(:save) do
    self.updated_at = Time.now
  end

  before(:create) do
    self.make_summary! # specific to posts
    self.make_slug!
  end

  def initialize(attributes={})
    self.created_at = Time.now
    self.updated_at = self.created_at
    super
  end

  def body_html
    RDiscount.new(self.body, :filter_html, :smart).to_html.strip
  end

  def url
    d = created_at
    "post/#{d.year}/#{d.month}/#{d.day}/#{slug}"
  end

  def permalink
  end

  def make_slug!
    self.slug = self.title.downcase.gsub(/ /, '_').gsub(/[^a-z0-9_]/, '').squeeze('_')
    # self.slug = self.class.first(:slug => slug) ? slug + "_#{Time.now.strftime("%Y-%d")}" : slug
  end

  def make_summary!
    if self.summary =~ /^\s+$/ || self.summary.nil?
      word_count = body.split(/\s/).size
      self.summary = (word_count <= 50 ? self.body : self.body[0..50])
    end
  end

  ### fetching

  def self.paginated(options={})
    per_page = options.delete(:per_page) || 10
    page = (options[:page] && options[:page] > 0 ) ? options.delete(:page) : 1

    all_posts = all(options)
    page_count = (all_posts.count.to_f / per_page).ceil

    options.merge!({ :limit => per_page, :offset => (page - 1) * per_page, :order => [:created_at.desc]})
    
    posts = all(options)
    [ page_count, posts ]
  end

  def self.circa(options={})
    year = options.delete(:year) || Time.now.year
    options.merge!({
      :created_at.gte => Date.new(year, 1, 1),
      :created_at.lt => Date.new(year + 1, 1, 1),
      :order => [:created_at.asc]
    })
    posts = all(options)
    [ 1, posts ]
  end
end

class GreekClass
  include DataMapper::Resource
  include Paperclip::Resource

  property :id, Integer, :serial => true
  property :name, String, :size => 255, :nullable => false
  property :slug, String, :size => 20, :nullable => false, :index => :unique # short code for greek letter

  property :banner_file_name, String
  property :banner_content_type, String
  property :banner_file_size, Integer

  validates_present :name, :slug
  validates_is_unique :slug

  has_attached_file :banner

  has n, :pledges, :class_name => 'Brother'
end

class Brother
  include DataMapper::Resource
  include Paperclip::Resource

  property :id, Integer, :serial => true
  property :greek_class_id, Integer, :nullable => false
  property :name, String, :size => 255, :nullable => false
  property :pledge_name, String, :size => 255, :nullable => false
  property :slug, String, :size => 255, :nullable => false, :index => :unique
  property :hometown, String, :size => 255
  property :major, String, :size => 255
  property :interests, String, :size => 255
  property :quote, String

  property :mugshot_file_name, String
  property :mugshot_content_type, String
  property :mugshot_file_size, Integer

  validates_present :greek_class_id, :name, :pledge_name, :slug
  validates_is_unique :pledge_name, :slug

  has_attached_file :mugshot

  belongs_to :greek_class, :class_name => 'GreekClass'

  before(:save) do
    self.make_slug!
  end

  def url
    "roster/#{self.greek_class.short}/brother/#{self.slug}"
  end

  def make_slug!
    self.slug = self.pledge_name.downcase.gsub(/ /, '_').gsub(/[^a-z0-9_]/, '').squeeze('_')
  end
end
