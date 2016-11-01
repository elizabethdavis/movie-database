require 'sinatra'
require 'sqlite3'
require 'simplehttp'
require 'json'
require 'ostruct'

set :port, 8080
set :static, true
set :public_folder, "static"
set :views, "views"

db = SQLite3::Database.open "movies.db"
db.execute "CREATE TABLE IF NOT EXISTS Movies(Id INTEGER PRIMARY KEY, 
        Title TEXT, Year INTEGER, Review TEXT)"

get '/' do
    erb :welcome_form
end

#--------------------------------------------------------------------------------------
# Add a new movie to the database
#--------------------------------------------------------------------------------------
get '/new-movie/' do 
    erb :add
end 

post '/new-movie/' do
    year = params[:year] || "0000"
    title = params[:title] || "no movie here"

 begin
    db = SQLite3::Database.open "movies.db"
    #db.execute( "INSERT INTO Movies (Title, Year) VALUES('#{title}', '#{year}')")

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


    obj[:Search].each do |movie|
    
    # get id of movie item
    id = movie['imdbID']
    
    # search by id 
    single_omdb_search_options_by_id = "i=#{id}&plot=short&r=json&tomatoes=true"
    id_single_full_url = omdb_url + single_omdb_search_options_by_id

    response = SimpleHttp.get id_single_full_url 
    
    # ostructify JSON response
    obj = JSON.parse(response, object_class: OpenStruct)
    
    # put out some fields. not all results have a tomatoRating
    puts "Title: " + obj.Title
    puts "Year: " + obj.Year 
    puts "Rotten Tomatoes: " + obj.tomatoRating
    puts "IMDB id: " + id
end


   
        #db.execute( "INSERT INTO Movies (Title, Year) VALUES('#{title}', '#{year}')")

    erb :add_confirm, :locals => {'year' => year, 'title' => title, 'obj' => obj}

    rescue SQLite3::Exception => e 
    
    puts "Exception occurred"
    puts e
    ensure
        db.close if db
    end
end


#--------------------------------------------------------------------------------------
# Delete a movie from the database
#--------------------------------------------------------------------------------------
get '/delete-movie/' do 
    erb :delete_input
end 

post '/delete-movie/' do
    title = params[:title] || "Enter Movie Title"
    erb :delete_confirm, :locals => {'title' => title}

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
    
    redirect '/'
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
        db.execute( "INSERT INTO Movies (Title, Review) VALUES('#{title}', '#{review}')")

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
    db = params[:db]

    begin
        db = SQLite3::Database.open "movies.db"
        db.execute "SELECT * FROM Movies" do |row|
            puts row
        end
        

    rescue SQLite3::Exception => e 
    
    puts "Exception occurred"
    puts e
    
    ensure
        db.close if db
    end

    erb :view_movies
end