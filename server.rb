require 'csv'
require 'pry'
require 'sinatra'
require 'redis'

# Returns a connection to the appropriate Redis server
def get_connection
  if ENV.has_key?("REDISCLOUD_URL")
    Redis.new(url: ENV["REDISCLOUD_URL"])
  else
    Redis.new
  end
end

# Retrieves all articles from the database
def find_articles
  redis = get_connection
  # Grabes the articles, starting with the first one, and ending with the last one (0, -1_
  serialized_articles = redis.lrange("slacker:articles", 0, -1)

  articles = []
  serialized_articles.each do |article|
    articles << JSON.parse(article, symbolize_names: true)
  end

  articles
end

# Persists a new article
def save_article(url, title, description)
  article = { url: url, title: title, description: description, domain: domain }

  redis = get_connection
  redis.rpush("slacker:articles", article.to_json)
end

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

  # Check to make sure that the user has filled out all the proper information


  CSV.open('feed.csv', 'a') do |row|
    row << [title,domain,url,description]
  end

  redirect '/'
end

set :views, File.dirname(__FILE__) + '/views'
set :public_folder, File.dirname(__FILE__) + '/public'
