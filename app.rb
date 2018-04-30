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
		slim(:computer_form)
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
				
				# Sätter en variabel som motsvarar priset på var och en av mina 9 datorer som byggs efter användarens önskemål. tier1=hög budget, tier2=medium budget, och tier3=låg budget

				price_for_gaming_tier1_computer = db.execute("SELECT SUM(price) FROM components WHERE use IS 'gaming' AND price_range IS '1'")
				price_for_gaming_tier2_computer = db.execute("SELECT SUM(price) FROM components WHERE use IS 'gaming' AND price_range IS '2'")
				price_for_gaming_tier3_computer = db.execute("SELECT SUM(price) FROM components WHERE use IS 'gaming' AND price_range IS '3'") 
				price_for_work_tier1_computer =	db.execute("SELECT SUM(price) FROM components WHERE use IS 'work' AND price_range IS '1'")
				price_for_work_tier2_computer =	db.execute("SELECT SUM(price) FROM components WHERE use IS 'work' AND price_range IS '2'")
				price_for_work_tier3_computer = db.execute("SELECT SUM(price) FROM components WHERE use IS 'work' AND price_range IS '3'")
				price_for_professional_tier1_computer =	db.execute("SELECT SUM(price) FROM components WHERE use IS 'professional' AND price_range IS '1'")
				price_for_professional_tier2_computer =	db.execute("SELECT SUM(price) FROM components WHERE use IS 'professional' AND price_range IS '2'")
				price_for_professional_tier3_computer =	db.execute("SELECT SUM(price) FROM components WHERE use IS 'professional' AND price_range IS '3'")

				# Hämtar användarens önskemål på sin dator 

				users_computer = db.execute("SELECT * FROM computer_info WHERE user_id=?", [session[:user_id]])

				if users_computer[0]["computer_use"] == "gaming"
					
					if users_computer[0]["budget"] > price_for_gaming_tier1_computer[0]["SUM(price)"]
						computer = db.execute("SELECT * FROM components WHERE use IS 'gaming' AND price_range IS '1'")
						slim(:my_computer, locals:{computer:computer, budget_error:"", total_cost:price_for_gaming_tier1_computer[0]["SUM(price)"]}) #Ta bort budget_error ifall det går
					
					elsif users_computer[0]["budget"] > price_for_gaming_tier2_computer[0]["SUM(price)"]

						computer = db.execute("SELECT * FROM components WHERE use IS 'gaming' AND price_range IS '2'")
						slim(:my_computer, locals:{computer:computer, budget_error:"", total_cost:price_for_gaming_tier2_computer[0]["SUM(price)"]}) #Ta bort budget_error ifall det går
				
					else
						if users_computer[0]["budget"] > price_for_gaming_tier3_computer[0]["SUM(price)"]

							computer = db.execute("SELECT * FROM components WHERE use IS 'gaming' AND price_range IS '3'")
							slim(:my_computer, locals:{computer:computer, budget_error:"", total_cost:price_for_gaming_tier3_computer[0]["SUM(price)"]}) #Ta bort budget_error ifall det går

						else 
							
							budget_error_msg = "Can't find any recomended computer below this budget, this is the cheapest computer we could find for you:"
							computer = db.execute("SELECT * FROM components WHERE use IS 'gaming' AND price_range IS '3'")
							slim(:my_computer, locals:{computer:computer, budget_error:budget_error_msg, total_cost:price_for_gaming_tier3_computer[0]["SUM(price)"]}) 

						end
					end

				elsif users_computer[0]["computer_use"] == "work"
					
					if users_computer[0]["budget"] > price_for_work_tier1_computer[0]["SUM(price)"]

						computer = db.execute("SELECT * FROM components WHERE use IS 'work' AND price_range IS '1'")
						slim(:my_computer, locals:{computer:computer, budget_error:"", total_cost:price_for_work_tier1_computer[0]["SUM(price)"]}) #Ta bort budget_error ifall det går
					
					elsif users_computer[0]["budget"] > price_for_work_tier2_computer[0]["SUM(price)"]

						computer = db.execute("SELECT * FROM components WHERE use IS 'work' AND price_range IS '2'")
						slim(:my_computer, locals:{computer:computer, budget_error:"", total_cost:price_for_work_tier2_computer[0]["SUM(price)"]}) #Ta bort budget_error ifall det går
				
					else
						if users_computer[0]["budget"] > price_for_work_tier3_computer[0]["SUM(price)"]

							computer = db.execute("SELECT * FROM components WHERE use IS 'work' AND price_range IS '3'")
							slim(:my_computer, locals:{computer:computer, budget_error:"", total_cost:price_for_work_tier3_computer[0]["SUM(price)"]}) #Ta bort budget_error ifall det går

						else 

							budget_error = "Can't find any recomended computer below this budget, this is the cheapest computer we could find for you:"
							computer = db.execute("SELECT * FROM components WHERE use IS 'work' AND price_range IS '3'")
							slim(:my_computer, locals:{computer:computer, budget_error:budget_error, total_cost:price_for_work_tier3_computer[0]["SUM(price)"]})

						end
					end

				else users_computer[0]["computer_use"] == "professional"
					
					if users_computer[0]["budget"] > price_for_professional_tier1_computer[0]["SUM(price)"]

						computer = db.execute("SELECT * FROM components WHERE use IS 'professional' AND price_range IS '1'")
						slim(:my_computer, locals:{computer:computer, budget_error:"", total_cost:price_for_professional_tier1_computer[0]["SUM(price)"]}) #Ta bort budget_error ifall det går
					
					elsif users_computer[0]["budget"] > price_for_professional_tier2_computer[0]["SUM(price)"]

						computer = db.execute("SELECT * FROM components WHERE use IS 'professional' AND price_range IS '2'")
						slim(:my_computer, locals:{computer:computer, budget_error:"", total_cost:price_for_professional_tier2_computer[0]["SUM(price)"]}) #Ta bort budget_error ifall det går
				
					else
						if users_computer[0]["budget"] > price_for_professional_tier3_computer[0]["SUM(price)"]

							computer = db.execute("SELECT * FROM components WHERE use IS 'professional' AND price_range IS '3'")
							slim(:my_computer, locals:{computer:computer, budget_error:"", total_cost:price_for_professional_tier3_computer[0]["SUM(price)"]}) #Ta bort budget_error ifall det går

						else 

							budget_error = "Can't find any recomended computer below this budget, this is the cheapest computer we could find for you:"
							computer = db.execute("SELECT * FROM components WHERE use IS 'professional' AND price_range IS '3'")
							slim(:my_computer, locals:{computer:computer, budget_error:budget_error, total_cost:price_for_professional_tier3_computer[0]["SUM(price)"]})

						end
					end
				end
			end
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
		redirect('/home')
	end

end           
