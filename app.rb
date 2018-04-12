class App < Sinatra::Base

	get '/' do
		slim(:index)
	end

	get '/login' do
		slim(:login)
	end

	get '/register' do
		slim(:register)
	end

	post '/register' do
		db = SQLite3::Database.new('db/database.db')
		db.results_as_hash = true
		
		username = params["username"]
		password = params["password"]
		password_confirmation = params["confirm_password"]

		result = db.execute("SELECT id FROM users WHERE username=?", [username])
	end

end           
