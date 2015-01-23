require 'rubygems'
require 'active_record'
require 'sinatra'
require 'sinatra/reloader'
require 'pry'

set :port, 3000
set :bind, '0.0.0.0'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'shouter.sqlite'
)

class User < ActiveRecord::Base
  	
  	has_many :shouts

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

class Shout < ActiveRecord::Base

	belongs_to :user

	validates_presence_of :message
	validate :proper_message

	#- A created_at, which is the moment when the SHOUT is saved. It must be present.
	#- A likes counter, which must be an integer, at least 0
	private

  def proper_message
  	return errors.add(:message, 'No message') if message.nil?
  	if message.empty? || message.length > 200
  		errors.add(:message, 'Message length incorrect')
  	end
  end
end

get '/' do 
	@shouts = Shout.all.order('created_at DESC')
	erb :index
end

get '/best' do 
	@shouts = Shout.all.order('likes DESC')
	erb :index
end

get '/:handle' do 
	user = User.where(handle: params[:handle]).first
	@shouts = user.shouts.order('created_at DESC')
	erb :index
end

post '/send_shout' do 
	pass = params[:password]
	message = params[:message]
	usr = User.where(password: pass).first

	shout = Shout.create(user: usr, message: message, likes: 0)

	redirect('/')
end

post '/send_like' do
	shout = Shout.where(id: params[:id] ).first
	p ="="*50
	p params[:id]
	p shout.likes
	p ="="*50
	shout.update( likes: shout.likes + 1 )
	redirect('/')
end


#==== RSPEC TESTS =====

# describe 'User' do 
# 	describe 'register user tests' do 

# 		before do
# 			@u = User.new
# 			@u.name = "John"
# 			@u.password = "a"*20
# 			@u.handle = "helloworld"
# 		end

# 		it 'valid data, should return a valid user ' do
# 			expect(@u.valid?).to be_truthy 
# 		end
# 		it 'no name, should return invalid user' do 
# 			@u.name = nil
# 			expect(@u.valid?).to be_falsey
# 		end
# 		it 'no password, should return invalid user' do 
# 			@u.password = nil
# 			expect(@u.valid?).to be_falsey
# 		end
# 		it 'password length incorrect, should return invalid user' do 
# 			@u.password = 'hello'
# 			expect(@u.valid?).to be_falsey
# 		end
# 		it 'no handle, should return invalid user' do 
# 			@u.handle = nil
# 			expect(@u.valid?).to be_falsey
# 		end
# 		it 'handle uppercase characters, should return invalid user' do 
# 			@u.handle = 'Hello'
# 			expect(@u.valid?).to be_falsey
# 		end
# 		it 'handle space characters, should return invalid user' do 
# 			@u.handle = 'hello world'
# 			expect(@u.valid?).to be_falsey
# 		end
# 	end
# end

# describe 'Shouts' do 
# 	describe 'shout creation tests' do 

# 		before do
# 			@u = User.new
# 			@u.name = "John"
# 			@u.password = "a"*20
# 			@u.handle = "hello"

# 			@s = Shout.new
# 			@s.user = @u
# 			@s.message = "hello world"
# 		end

# 		it 'shout created correctly' do 
# 			expect(@s.valid?).to be_truthy
# 		end
# 		it 'shout message nil, should return error' do 
# 			@s.message = nil
# 			expect(@s.valid?).to be_falsey
# 		end
# 		it 'shout message empty, should return error' do 
# 			@s.message = ""
# 			expect(@s.valid?).to be_falsey
# 		end
# 		it 'shout message to length, should return error' do 
# 			@s.message = "a"*201
# 			expect(@s.valid?).to be_falsey
# 		end
# 	end
# end