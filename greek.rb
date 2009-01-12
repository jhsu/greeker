require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'yaml'

root_dir = File.dirname(__FILE__)
$:.unshift "#{root_dir}/lib"
$:.unshift "#{root_dir}"

configure :development do
  DataMapper.setup(:default, "sqlite3:///#{Dir.pwd}/development.db")
  DataMapper.auto_migrate!
  
  CONFIG = YAML.load_file("#{root_dir}/config/chapter.yml")
  GENERAL = CONFIG['general']
  CHAPTER = CONFIG['chapter']
  SITE = CONFIG['site']

  require 'ostruct'
  Greek = OpenStruct.new(
    :title => GENERAL['name'],
    :short => GENERAL['short'],
    :chapter => CHAPTER['name'],
    :tel => CHAPTER['tel'],
    :email => CHAPTER['email'],
    :begin_year => SITE['begin_year'],
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
  page = params[:page] ? params[:page].to_i : 1
  page_count, posts = Post.paginated(:page => page, :event => false)
  erb :index, :locals => { :posts => posts, :page_count => page_count, :page => page }
end

get '/events' do
  page = params[:page] ? params[:page].to_i : 1
  page_count, posts = Post.paginated(:page => page, :event => true)
  erb :index, :locals => { :posts => posts, :page_count => page_count, :page => page }
end

### Posts archive

get '/circa/:year' do
  page_count, posts = Post.circa(:year => params[:year].to_i)
  erb :index, :locals => { :posts => posts, :page_count => page_count, :page => 1}
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
  post.event = true if params[:event]
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
  erb :page, :locals => { :page => page }
end

get '/contact' do
  page = Page.first(:slug => 'contact')
  erb :page, :locals => { :page => page }
end

get '/media' do
  page = Page.first(:slug => 'media')
  erb :page, :locals => { :page => page }
end

### Page Admin

get '/:page/edit' do
  page = Page.first(:slug => params[:page])
  stop [ 404, "Page Not Found" ] unless page
  erb :edit_page, :locals => { :page => page, :url => page.url }
end

put '/:page' do
end

### Roster

get '/roster' do
  greek_classes = GreekClass.all
  erb :roster, :locals => { :greek_classes => greek_classes }
end

get '/roster/:klass' do
  greek_class = GreekClass.first(:slug => params[:klass])
  brothers = greek_class.pledges
  erb :brothers, :locals => { :brothers => brothers, :greek_class => greek_class }
end

### Roster Admin

get '/add_brother' do
  greek_classes = GreekClass.all
  erb :pick_class, :locals => { :greek_classes => greek_classes }
end

get '/roster/:klass/brothers/new' do
  brother = Brother.new
  erb :edit_brother, :locals => { :brother => brother, :url => "/roster/#{params[:klass]}/new" }
end

post '/roster/:klass/brothers' do
end

get '/roster/:klass/brother/:pledge_name/edit' do
  brother = Brother.first(:slug => params[:pledge_name])
  erb :edit_brother, :locals => { :brother => brother, :url => brother.url }
end

put '/roster/:klass/brother/:pledge_name' do
  brother = Brother.first(:slug => params[:pledge_name])
  brother.update_attributes(:name => params[:name], :pledge_name => params[:pledge_name])
  redirect "/roster/#{params[:klass]}/brothers"
end

delete '/roster/:klass/brother/:pledge_name' do
  brother = Brother.first(:slug => params[:pledge_name])
  brother.destroy
  redirect "/roster/#{params[:klass]}/brothers"
end
