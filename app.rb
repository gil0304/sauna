require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models.rb'
require 'dotenv/load'

enable :sessions

before do
  Dotenv.load
  Cloudinary.config do |config|
    config.cloud_name = ENV["CLOUD_NAME"]
    config.api_key = ENV["CLOUDINARY_API_KEY"]
    config.api_secret = ENV["CLOUDINARY_API_SECRET"]
  end
end

helpers do
  def current_user
    User.find_by(id: session[:user])
  end
end

before '/' do
  redirect '/signin' if current_user.nil?
end

get '/' do
  @mycontents = current_user.contents
  @contents = Content.all
  erb :index
end

get '/signin' do
  erb :sign_in
end

post '/signin' do
  user = User.find_by(mail: params[:mail])
  if user && user.authenticate(params[:password])
    session[:user] = user.id
    redirect '/'
  else
    redirect '/signin'
  end
end

get '/signup' do
  erb :sign_up
end

post '/signup' do
  user = User.create(name: params[:name], mail: params[:mail], password: params[:password], password_confirmation: params[:password_confirmation])
  if user.persisted?
    session[:user] = user.id
    redirect '/'
  else
    redirect '/signup'
  end
end

get '/signout' do
  session[:user] = nil
  redirect '/'
end

before '/new/content' do
  redirect '/signin' if current_user.nil?
end

get '/new/content' do
  erb :new_content
end

post '/new/content' do
  if current_user.nil?
    redirect '/signin'
  else
    img_url = ''
    if params[:file]
      img = params[:file]
      tempfile = img[:tempfile]
      upload = Cloudinary::Uploader.upload(tempfile.path)
      img_url = upload["url"]
    end
    current_user.contents.create(
      title: params[:title],
      body: params[:body],
      sauna_url: params[:sauna_url],
      img_url: img_url
    )
    redirect '/'
  end
end

get '/content/:id' do
  @content = Content.find(params[:id])
  erb :content
end
