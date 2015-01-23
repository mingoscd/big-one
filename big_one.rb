# SHOUTER: THE FINAL BOSS

# - The Model(s)
#   - We will have two models, User and Shout.
#   - The User model will have:
#     - A handle, which must be present and unique. It should not contain spaces, and be only characters in downcase.
#     - A password, which must be present and will be generated randomly when creating a User. It will be 20 characters long and unique.

#   - The Shout model will have:
#     - A message, with at least one character and at most 200. (BECAUSE SHOUTING NEEDS MORE CHARACTERS THAN TWITTING)
#     - A many-to-one relation to a User, which must be present.
#     - A created_at, which is the moment when the SHOUT is saved (this behaviour must be implemented within the class, not outside). It
#     must be present.
#     - A likes counter, which must be an integer, at least 0.
# - The website
#   - We will have a main page where we can SHOUT. There will be a form in the top that takes care of that with a wide text field for the
#   message, and an input button in order to SHOUT.
#   - In order to authenticate ourselves for SHOUTING, we will just add an input field for the password. This will identify ourselves!
#   - The main page will also have a list of SHOUTS, sorted newest first, rendering the name, the handle for the user, and the message
#   itself.
#   - Plus, every SHOUT will show the number of likes, and have a “Like” button that will increase the number of likes for a SHOUT; after
#   clicking the button we will be redirected to the main page again.
#   - We are going to use the likes from each SHOUT to add a new route, called (‘/best’), which will show the SHOUTS sorted by the number
#   of likes.
#   - Similarly, we are going to have a route called ‘/:handle’ which basically shows all the SHOUTS from the user attached to that
#   specific handle.

# In order to make development easier, create some users using PRY, because we won’t have any UI to create users via the website.

# Note: you will find a skeleton .rb file and an empty SQLite database for all this in Slack!
require 'rubygems'
require 'active_record'
require 'sinatra'
require 'sinatra/reloader'

set :port, 3000
set :bind, '0.0.0.0'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'shouter.sqlite'
)

class User < ActiveRecord::Base

  validates_presence_of :name, :handle, :password
  validates_uniqueness_of :handle, :password 
  validate :proper_password
  validate :proper_handle

private

  def proper_handle
  	return errors.add(:handle, 'no handle') if handle.nil?
  	unless handle.downcase == handle
  		errors.add(:handle, 'contains uppercase characters')
  	end
  	if handle.include?(" ")
  		errors.add(:handle, 'contains space characters')
  	end
  end

  def proper_password
  	return errors.add(:password, 'no password') if password.nil?
  	unless password.length == 20
  		errors.add(:password, 'password length incorrect')
  	end
  end
end

describe 'User' do 
	before do
		@u = User.new
		@u.name = "John"
		@u.password = "abcdefghijklmnopqrst"
		@u.handle = "hello"
	end
	describe 'register user tests' do 
		it 'valid data, should return a valid user ' do 
			expect(@u.valid?).to be_truthy 
		end
		it 'no name, should return invalid user' do 
			@u.name = nil
			expect(@u.valid?).to be_falsey
		end
		it 'no password, should return invalid user' do 
			@u.password = nil
			expect(@u.valid?).to be_falsey
		end
		it 'password length incorrect, should return invalid user' do 
			@u.password = 'hello'
			expect(@u.valid?).to be_falsey
		end
		it 'no handle, should return invalid user' do 
			@u.handle = nil
			expect(@u.valid?).to be_falsey
		end
		it 'handle uppercase characters, should return invalid user' do 
			@u.handle = 'Hello'
			expect(@u.valid?).to be_falsey
		end
		it 'handle space characters, should return invalid user' do 
			@u.handle = 'hello world'
			expect(@u.valid?).to be_falsey
		end
	end
end