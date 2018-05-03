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
		slim(:home)
	end

	get '/home' do
		slim(:home)
	end

	get '/error' do
		slim(:error)
	end

	get '/login' do
		slim(:login)
	end

	get '/register' do
		slim(:register)
	end

	get '/computer_form' do
		db = SQLite3::Database.new('db/database.db')
		db.results_as_hash = true

		result = db.execute("SELECT id FROM computer_info WHERE user_id=?", [session[:user_id]])

		#Gör så att ifall man redan har svarat på formuläret eller inte är inloggad ska man inte komma in på den

		if(session[:user_id])
			if result.empty?
				slim(:computer_form)
			else
				redirect('/my_computer')
			end
		else
			set_error("You must be logged in to access this page!")
			redirect('/error')
		end
	end

	get '/my_profile' do
		slim(:my_profile)
	end

	get '/my_computer' do
		if(session[:user_id])
			db = SQLite3::Database.new('db/database.db')
			db.results_as_hash = true

			result = db.execute("SELECT id FROM computer_info WHERE user_id=?", [session[:user_id]])

			# Kollar om använderen har svarat på formuläret tidigare
		
			if result.empty?
				redirect('/computer_form')
			else

				users_computer = db.execute("SELECT * FROM computer_info WHERE user_id=?", [session[:user_id]])
				budget = users_computer[0]["budget"].to_i
				use = users_computer[0]["computer_use"]

				# Loopar igenom alla prisklasser för det användninsområdet som är kopplat till användaren 
				# Sedan "break:ar" den loopen då prisklassen passar användarens budget och skickar senare den relevanta komponenterna till slim-filen

				i = 1
				while i <= 3
					computer = db.execute("SELECT * FROM components WHERE use IS ? AND price_range IS ?", [use, i])

					total = 0
					computer.each do |part|
						total += part["price"].to_i
					end

					if total.to_i < budget.to_i

						break

					elsif i == 3
						
						# Felhantering om användarens budget är mindre än den lägsta prisklassen
						
						error = true
						break
					end

					i += 1
				end

				# Lägger till vilka butiker där komponenterna går att köpa, sedan läggs dessa butiker in i "computer" som sedan skickas till slim-filen

				models = []
				computer.each_with_index do |part, i|

					this_is_id = db.execute('SELECT id FROM components WHERE model IS ? LIMIT 1', [part["model"]]).first.first
					
					stores = db.execute("SELECT store FROM stores WHERE id IN (SELECT store_id FROM component_store WHERE component_id IS ?)", this_is_id[1])

					arr = []
					stores.each do |store|
						arr << store["store"]
					end

					computer[i]["stores"] = arr

				end

				if error
					slim(:my_computer, locals:{computer: computer, budget_error:"Couldn't find a recommended computer matching your budget, this is the cheapest one we could find:", total_cost: total})
				else
					slim(:my_computer, locals:{computer: computer, budget_error:"", total_cost: total})
				end

			end
		else
			set_error("You must be logged in to access this page!")
			redirect('/error')
		end
	end

	post '/computer_info' do
		db = SQLite3::Database.new('db/database.db')

		budget = params["budget"]
		computer_use = params["computer_use"]
		db.execute("INSERT INTO computer_info(budget, computer_use, user_id) VALUES (?,?,?)", [budget, computer_use, session[:user_id]])

		redirect('/my_computer')

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

	post '/logout' do
		session[:user_id] = nil
		redirect('/login')
	end

end
