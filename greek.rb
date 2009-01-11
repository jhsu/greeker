require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'dm-paperclip'
require 'dm-is-paginated'
require 'rdiscount'

root_dir = File.dirname(__FILE__)
$:.unshift "#{root_dir}/lib"
$:.unshift "#{root_dir}"

configure :development do
  DataMapper.setup(:default, "sqlite3:///#{Dir.pwd}/development.db")
  DataMapper.auto_migrate!
  
  require 'ostruct'
  Greek = OpenStruct.new(
    :title => 'Nu Alpah Phi',
    :chapter => 'Delta',
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
  page = params[:page] ? params[:page].to_i : 1
  page_count, posts = Post.paginated(:page => page)
  erb :index, :locals => { :posts => posts, :page_count => page_count, :page => page }
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

get '/news' do
  posts = Post.news
  erb :section, :locals => { :posts => posts }
end

get '/events' do
  posts = Post.events
  erb :section, :locals => { :posts => posts }
end

### Posts archive

get '/circa/:year' do

end

### Posts Admin

get '/posts/new' do
  post = Post.new
  erb :edit_post, :locals => { :post => post, :url => '/posts' }
end

post '/posts' do
  post = Post.new( :title => params[:title],
                   :body => params[:body],
                   :summary => params[:summary])
  post.event = true if params[:event]
  post.save
  redirect "/#{post.url}"
end

get '/post/:year/:month/:day/:slug/edit' do
  post = Post.first(:slug => params[:slug])
  erb :edit_post, :locals => { :post => post, :url => "/#{post.url}"}
end

put '/post/:year/:month/:day/:slug' do
  post = Post.first(:slug => params[:slug])
  post.title = params[:title]
  post.body = params[:body]
  post.summary = params[:summary]
  post. true if params[:event]
  post.save
  redirect "/#{post.url}"
end

delete '/post/:year/:month/:day/:slug' do
  post = Post.first(:slug => params[:slug])
  post.destroy
  redirect "/"
end

### Pages

get '/about' do
  page = Page.first(:slug => 'about')
end

get '/contact' do
  page = Page.first(:slug => 'contact')
end

get '/media' do
  page = Page.first(:slug => 'media')
end

### Roster

get '/roster' do
end

get '/roster/:klass/brothers' do
end

### Roster Admin

get '/roster/:klass/brothers/new' do
end

post '/roster/:klass/brothers' do
end

get '/roster/:klass/brother/:pledge_name/edit' do
  # brother = Brother.first(:pledge_name => params[:pledge_name)
  # erb :edit_brother, :locals => { :brother => brother, :url => brother.url }
end

put '/roster/:klass/brother/:pledge_name' do
  # brother = Brother.first(:pledge_name => params[:pledge_name)
  # brother.update_attributes(:name => params[:name], :pledge_name => params[:pledge_name])
  redirect "/roster/#{params[:klass]}/brothers"
end

delete '/roster/:klass/brother/:pledge_name' do
  # brother = Brother.first(:pledge_name => params[:pledge_name])
  # brother.destroy
  redirect "/roster/#{params[:klass]}/brothers"
end
