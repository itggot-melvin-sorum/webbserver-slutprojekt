class App < Sinatra::Base

	enable :sessions

	def set_error(error_message)
		session[:error] = error_message
	end

	def get_error()
		error = session[:error]
		session[:error] = nil
		return error
	end

	get '/' do
		slim(:index)
	end

	get '/home' do
		slim(:home)
	end

	get('/error') do
		slim(:error)
	end

	get '/login' do
		slim(:login)
	end

	get '/register' do
		slim(:register)
	end

	get '/computer_form' do
		slim(:computer_form)
	end

	get '/my_computer' do
		slim(:my_computer)
	end

	post 'computer_form' do
		db = SQLite3::Database.new('db/database.db')
		db.results_as_hash = true

		budget = params["budget"]
		computer_use = params["computer_use"]

		result = db.execute("SELECT id FROM users WHERE username=?", [username])

	end

	post '/register' do
		db = SQLite3::Database.new('db/database.db')
		db.results_as_hash = true
		
		username = params["username"]
		password = params["password"]
		password_confirmation = params["confirm_password"]

		result = db.execute("SELECT id FROM users WHERE username=?", [username])

		if result.empty?
			if password == password_confirmation
				password_digest = BCrypt::Password.create(password)

				db.execute("INSERT INTO users(username, password_digest) VALUES (?,?)", [username, password_digest])
				redirect('/login')
			else
				set_error("Passwords don't match")
				redirect('/error')
			end
		else
			set_error("Username already exists")
			redirect('/error')
		end	
	end

	post '/login' do 
		db = SQLite3::Database.new('db/database.db')
		db.results_as_hash = true
		username = params["username"]
		password = params["password"]

		result = db.execute("SELECT id, password_digest FROM users WHERE username=?", [username])

		if result.empty?
			set_error("Invalid Credentials")
			redirect('/error')
		end

		user_id = result.first["id"]
		password_digest = result.first["password_digest"]
		if BCrypt::Password.new(password_digest) == password
			session[:user_id] = user_id
			redirect('/my_computer')
		else 
			set_error("Invalid Credentials")
			redirect('/error')
		end
	end
end           
