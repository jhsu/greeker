require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'dm-paperclip'

root_dir = File.dirname(__FILE__)
$:.unshift "#{root_dir}/lib"
$:.unshift "#{root_dir}"

configure :development do
  DataMapper.setup(:default, "sqlite3:///#{Dir.pwd}/development.db")
  DataMapper.auto_migrate!
  
  require 'ostruct'
  Greek = OpenStruct.new(
    :title => 'Nu Alpah Phi',
    :author => 'admin',
    :url_base => 'http://localhost:4567/'
  )
end

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/lib')
require 'models'

helpers do
end

layout 'layout'

### Public

get '/' do
  posts = Post.latest(:limit => 20)
  erb :index, :locals => { :posts => posts }
end

get '/post/:year/:month/:day/:slug/' do
  redirect "/post/#{params[:year]}/#{params[:month]}/#{params[:day]}/#{params[:slub]}", 301
end

get '/post/:year/:month/:day/:slug' do
  post = Post.first(:slug => params[:slug])
  stop [ 404, "Page Not Found" ] unless post
  @title = post.title
  erb :post, :locals => { :post => post }
end

### Admin

get '/posts/new' do
  post = Post.new
  erb :edit_post, :locals => { :post => post }
end

post '/posts' do
end

get '/post/:year/:month/:day/:slug/edit' do
end

put '/post/:year/:month/:day/:slug' do
end
