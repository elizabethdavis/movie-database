require 'sinatra'
require 'sqlite3'
require 'simplehttp'
require 'json'
require 'ostruct'
require 'sinatra/reloader'

set :port, 8080
set :static, true
set :public_folder, "static"
set :views, "views"

# reloads the page automatically so that you don't need to shut down Sinatra each time
register Sinatra::Reloader

db = SQLite3::Database.open "movies.db"
db.execute "CREATE TABLE IF NOT EXISTS Movies(Id INTEGER PRIMARY KEY, 
        Title TEXT, Year INTEGER, Review TEXT, Tomato INTEGER)"
        
         #initialize arrays
configure do
     @@all_movies = Array.new
     @@movie_index = Array.new

end 

#--------------------------------------------------------------------------------------
# Welcome Page
#--------------------------------------------------------------------------------------
get '/' do
    erb :welcome_form
end

#--------------------------------------------------------------------------------------
# Search for a new movie
#--------------------------------------------------------------------------------------
get '/new-movie/' do 
    erb :add
end 

post '/new-movie/' do
    year = params[:year]
    title = params[:title]

 begin
    db = SQLite3::Database.open "movies.db"

    #set base url for omdb api
    omdb_url = "www.omdbapi.com/?"

    #set search options for: title, short plot, include tomatoes ratings
    single_omdb_search_options = "t=#{title}&plot=short&r=json&tomatoes=true"
    single_omdb_search_options_by_id = "i=#{@id}&plot=short&r=json&tomatoes=true"

    list_omdb_search_options = "s=#{title}&r=json"

    #combine options and base url
    title_single_full_url = omdb_url + single_omdb_search_options

    list_full_url = omdb_url + list_omdb_search_options

    # get JSON response for the search
    response = SimpleHttp.get list_full_url


    #turn the JSON into an object to make it easier to work with
    obj = JSON.parse(response, object_class: OpenStruct)
    
    # clear arrays
    
    @@all_movies.clear
    @@movie_index.clear 


    # access all movies that have the search phrase in their title
    obj[:Search].each do |movie|
        
        # get id of movie item
        id = movie['imdbID']
        
                
        # search by id 
        single_omdb_search_options_by_id = "i=#{id}&plot=short&r=json&tomatoes=true"
        id_single_full_url = omdb_url + single_omdb_search_options_by_id

        response = SimpleHttp.get id_single_full_url 
        
        # ostructify JSON response
        obj = JSON.parse(response, object_class: OpenStruct)

        # put all obj into an array
        
        
        @@all_movies << obj
        @@movie_index << id

    end

    erb :add_confirm, :locals => {'year' => year, 'title' => title, 'obj' => obj}

    rescue SQLite3::Exception => e 
        puts "Exception occurred"
        puts e
    
    ensure
        db.close if db
    end
end

#--------------------------------------------------------------------------------------
# Add selected movie to the database
#--------------------------------------------------------------------------------------
post '/add/' do
#     year = params[:year]
#     title = params[:title]
#     tomato = params[:tomato]
    
    id = params[:array_index]
     
    year = @@all_movies[id.to_i]['Year']
    title = @@all_movies[id.to_i]['Title']
    tomato = @@all_movies[id.to_i]['tomatoRating']
    

    begin
    db = SQLite3::Database.open "movies.db"
    db.execute( "INSERT INTO Movies (Title, Year, Tomato) SELECT '#{title}', '#{year}', '#{tomato}' WHERE NOT EXISTS(SELECT * FROM Movies WHERE Title = '#{title}' AND Year = '#{year}' AND Tomato = '#{tomato}')")
    puts "inserting '#{id}' into the database"

    rescue SQLite3::Exception => e 
    
    puts "Exception occurred"
    puts e
    
    ensure
        db.close if db
    end
    
    erb :add_confirm

end

#--------------------------------------------------------------------------------------
# Delete a movie from the database
#--------------------------------------------------------------------------------------
get '/delete-movie/' do 
    erb :delete_input
end 

post '/delete-movie/' do
    title = params[:title]

    begin
        db = SQLite3::Database.open "movies.db"

    rescue SQLite3::Exception => e 
    
    puts "Exception occurred"
    puts e
    
    ensure
        db.close if db
    end
end

delete '/delete-movie/' do
    title = params[:title]

    begin
     db = SQLite3::Database.open "movies.db"
     db.execute "DELETE FROM Movies WHERE Title = '#{title}'"
        puts "Your data has been deleted from the database!"
     

    rescue SQLite3::Exception => e 
        
        puts "Exception occurred"
        puts e
        
        ensure
            db.close if db
        end

    erb :delete_confirm, :locals => {'title' => title}

end


#--------------------------------------------------------------------------------------
# Add a personal review of the movie to the database
#--------------------------------------------------------------------------------------
get '/review-movie/' do 
    erb :input_review
end 

post '/review-movie/' do
    title = params[:title]
    review = params[:review]

   
    begin
        db = SQLite3::Database.open "movies.db"
        db.execute "UPDATE Movies SET Review='#{review}' WHERE Title='#{title}'"

    rescue SQLite3::Exception => e 
    
    puts "Exception occurred"
    puts e
    
    ensure
        db.close if db
    end

    erb :review_output, :locals => {'title' => title, 'review' => review}

end

#--------------------------------------------------------------------------------------
# View movies in the database
#--------------------------------------------------------------------------------------
get '/view-movie/' do
    @movies = Array.new 
    begin
        db = SQLite3::Database.open "movies.db"
        db.execute "SELECT * FROM Movies" do |row|
            @movies << row 
        end
       
    rescue SQLite3::Exception => e 
    
    puts "Exception occurred"
    puts e
    
    ensure
        db.close if db
    end

    erb :view_movies
end

#--------------------------------------------------------------------------------------
# Edit movies in the database
#--------------------------------------------------------------------------------------
get '/edit-review/' do
    erb :edit
end

post '/edit-movie-review/' do
    review = params[:review]
    title = params[:title]

    begin
        db = SQLite3::Database.open "movies.db"
        db.execute "UPDATE Movies SET Review='#{review}' WHERE Title='#{title}'"

    rescue SQLite3::Exception => e 
    
    puts "Exception occurred"
    puts e
    
    ensure
        db.close if db
    end

    redirect '/'
end

#--------------------------------------------------------------------------------------
# End of code
#--------------------------------------------------------------------------------------