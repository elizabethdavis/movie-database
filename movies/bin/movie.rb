require 'sinatra'
require 'sqlite3'

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
    year = params[:year] || "Hi There"
    title = params[:title] || "Nobody"

    begin
    	db = SQLite3::Database.open "movies.db"
    	db.execute "CREATE TABLE IF NOT EXISTS Movies(Id INTEGER PRIMARY KEY, 
        Title TEXT, Year INTEGER)"
        db.execute( "INSERT INTO Movies (Title, Year) VALUES('#{title}', '#{year}')")
    puts "Your movie has been entered into the database!"
    erb :add_confirm, :locals => {'year' => year, 'title' => title}

    rescue SQLite3::Exception => e 
    
    puts "Exception occurred"
    puts e
    year
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
    new_title = params[:title] || "Enter Movie Title"
    new_year = params[:year] || "0000"

    begin
        db = SQLite3::Database.open "movies.db"
        db.execute "CREATE TABLE IF NOT EXISTS Movies(Id INTEGER PRIMARY KEY, 
        Title TEXT, Year INTEGER)"
        db.execute( "UPDATE Movies SET Title='#{title}' WHERE Year='#{year}'")
        erb :edit_confirm, :locals => {'year' => year, 'title' => title}

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
    	db.execute "CREATE TABLE IF NOT EXISTS Movies(Id INTEGER PRIMARY KEY, 
        Title TEXT, Year INTEGER)"


    rescue SQLite3::Exception => e 
    
    puts "Exception occurred"
    puts e
    
    ensure
        db.close if db
    end
end

## delete route
delete '/delete-movie/' do
 title = params[:title]

begin
 ### delete code, database execute, etc.
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
    erb :hello_form
end 