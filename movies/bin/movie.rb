require 'sinatra'
require 'sqlite3'
require 'simplehttp'
require 'json'
require 'ostruct'

set :port, 8080
set :static, true
set :public_folder, "static"
set :views, "views"

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

    omdb_url = "www.omdbapi.com/?"

    #set search options for: title, short plot, include tomatoes ratings
    omdb_search_options = "t=#{title}&plot=short&r=json&tomatoes=true"

    #combine options and base url
    full_url = omdb_url + omdb_search_options

    response = SimpleHttp.get full_url

    obj = JSON.parse(response, object_class: OpenStruct)

    begin
    	db = SQLite3::Database.open "movies.db"
        db.execute "CREATE TABLE IF NOT EXISTS Movies(Id INTEGER PRIMARY KEY, 
        Title TEXT, Year INTEGER)"
        db.execute( "INSERT INTO Movies (Title, Year) VALUES('#{title}', '#{year}')")


    erb :add_confirm, :locals => {'year' => year, 'title' => title, 'obj' => obj}

    rescue SQLite3::Exception => e 
    
    puts "Exception occurred"
    puts e
	ensure
	    db.close if db
	end
end



#--------------------------------------------------------------------------------------
# Edit an existing movie in the database
#--------------------------------------------------------------------------------------
get '/edit-movie/' do 
    erb :edit
end 

post '/edit-movie/' do
    title = params[:title] || "Enter Movie Title"
    year = params[:year] || "0000"
    new_title = params[:new_title]

    begin
        db = SQLite3::Database.open "movies.db"
        db.transaction
        db.execute( "UPDATE Movies SET Title='#{new_title}' WHERE Title = '#{title} AND Year='#{year}'")
        erb :edit_confirm, :locals => {'year' => year, 'new_title' => new_title}
        db.commit

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
        erb :delete_confirm, :locals => {'title' => title}

    rescue SQLite3::Exception => e 
        
        puts "Exception occurred"
        puts e
        
        ensure
            db.close if db
        end
end


#--------------------------------------------------------------------------------------
# Add a personal review of the movie to the database
#--------------------------------------------------------------------------------------
get '/review-movie/' do 
    erb :review_form
end 

post '/review-movie/' do
    data = params[:data]

    
end
