require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'dm-paperclip'

root_dir = File.dirname(__FILE__)
$:.unshift "#{root_dir}/lib"
$:.unshift "#{root_dir}"



class Post
  include DataMapper::Resource
  include Paperclip::Resource

  property :id, Integer, :serial => true
  property :slug, String, :size => 255, :nullable => false, :index => :unique
  property :title, String, :size => 255, :nullable => false
  property :summary, Text, :lazy => false
  property :event, Boolean, :default => false
  property :created_at, DateTime, :nullable => false, :index => true
  property :updated_at, DateTime, :nullable => false
  property :body, Text

  property :flyer_file_name, String
  property :flyer_content_type, String
  property :flyer_file_size, Integer
  property :flyer_updated_at, DateTime

  has_attached_file :flyer

  alias_method :event, :event?

  before(:save) { self.updated_at = Time.now }

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

if development?
  Post.auto_migrate!
  Event.auto_migrate!
end

get '/' do
  @posts = Post.all + Event.all
end
