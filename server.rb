require 'csv'
require 'pry'
require 'sinatra'

def read_from_csv(file)
  articles = []
  CSV.foreach(file, headers: true, header_converters: :symbol) do |article|
    articles << article.to_hash
  end
  articles
end



csv_feed = read_from_csv('feed.csv')

#------------------------------------------ Routes ------------------------------------------
get '/' do
  @feed = csv_feed
  erb :index
end

post '/post_art' do

  # Store user input into variables
  title = params['title']
  domain = params['domain']
  url = params['url']
  description = params['description']

  CSV.open('feed.csv', 'a') do |row|
    row << [title,domain,url,description]
  end

  redirect '/'
end

set :views, File.dirname(__FILE__) + '/views'
set :public_folder, File.dirname(__FILE__) + '/public'
