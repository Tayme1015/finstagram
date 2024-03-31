# Methods
# def humanized_time_ago(time_ago_in_minutes)
  
#   if time_ago_in_minutes >= 60

#     "#{time_ago_in_minutes / 60} hours ago"

#   elsif time_ago_in_minutes < 1

#     "just a moment ago"

#   else
#     "#{time_ago_in_minutes} minutes ago"

#   end

# end

helpers do
  # returns an Object (User) or nil
  def current_user
    User.find_by(id: session[:user_id])
  end

  # return a boolean (true or false)
  def logged_in?
    !!current_user
  end
end

# When a browser requests the root of the application
get '/' do 

  @finstagram_posts = FinstagramPost.order(created_at: :desc)  
  erb(:index)
  
end
#   @finstagram_post_shark = {
#     username: "sharky_j",
#     avatar_url: "https://live.staticflickr.com/65535/52358606250_01c667c5da_w.jpg",
#     photo_url: "https://live.staticflickr.com/65535/52358421508_786aa10e2c_c.jpg",
#     humanized_time_ago: humanized_time_ago(15),
#     like_count: 0,
#     comment_count: 1,
#     comments: [{
#       username: "sharky_j",
#       text: "Out for the long weekend... too embarrassed to show y'all the beach bod!"
#     }]
#   }

#   @finstagram_post_whale = {
#     username: "kirk_whalum",
#     avatar_url: "https://live.staticflickr.com/65535/52358421348_f34c7996b1.jpg",
#     photo_url: "https://live.staticflickr.com/65535/52357237337_1cc718f6a7_4k.jpg",
#     humanized_time_ago: humanized_time_ago(65),
#     like_count: 0,
#     comment_count: 1,
#     comments: [{
#       username: "kirk_whalum",
#       text: "#weekendvibes"
#     }]
#   }

#   @finstagram_post_marlin = {
#     username: "marlin_peppa",
#     avatar_url: "https://live.staticflickr.com/65535/52358415933_0a0e6bc35f_3k.jpg",
#     photo_url: "https://live.staticflickr.com/65535/52358494794_f88b160d15_4k.jpg",
#     humanized_time_ago: humanized_time_ago(190),
#     like_count: 0,
#     comment_count: 1,
#     comments: [{
#       username: "marlin_peppa",
#       text: "lunchtime! ;)"
#     }, {username: "tuna_t",
#     text: "Looks yummy!"}]
#   }

#   @finstagram_posts = [@finstagram_post_shark, @finstagram_post_whale, @finstagram_post_marlin]

#   # This code will return "marlin_peppa"
#   #finstagram_post[:comments][0][:username]

# # Stop




# This option is not as great

  # # if the time_ago_in_minutes is greater than 60
  # if time_ago_in_minutes > 60
    
  #   # return this string
  #   "more than an hour"

  # # if it's one hour
  # elsif time_ago_in_minutes == 60

  #   # return this string
  #   "an hour"

  # # if it's less than a minute
  # elsif time_ago_in_minutes <=1

  #   #return this string 
  #   "just a moment ago"

  # # if it's less than or equal
  # else

  #   # return this instead
  #   "less than an hour"

  # end

  # A more efficient way of tracking the time

  # if time_ago_in_minutes >=60

  #   # with #{} we can do a calculation
  #   "#{time_ago_in_minutes / 60} hours ago"

  # elsif time_ago_in_minutes < 1
  #   # for less than a minute
  #   "just a moment ago"
  
  
  # else
  #   "#{time_ago_in_minutes} minutes ago"

  # end


  get "/signup" do
    @user = User.new

    erb(:signup)

  end

  post '/signup' do
    
    # grab user input values from params defined in the form
    email      = params[:email]  
    avatar_url = params[:avatar_url]
    username   = params[:username]
    password   = params[:password]

    # instantiate and save a User
    @user = User.new({ email: email, avatar_url: avatar_url, username: username, password: password })

    # if all user params are present
    if @user.save

      redirect to ('/login')

    else

      erb(:signup)

    end

  end


  get "/login" do

    erb(:login)

  end


  post "/login" do

    username   = params[:username]
    password   = params[:password]

    #1. Find user by username
    
    @user = User.find_by(username: username)

    #2. If the user exists and check if that user's password matches the password input

    if @user && @user.password == password

      session[:user_id] = @user.id

      redirect to("/")


    else

      @error_message = "Login failed"

      erb(:login)

    end

  end
  
get "/logout" do

  session[:user_id] = nil

  redirect to('/')

end

# Before handler for '/finstagram_posts/new'
before '/finstagram_posts/new' do
  redirect to('/login') unless logged_in?
end

get '/finstagram_posts/new' do

  @finstagram_post = FinstagramPost.new
  erb(:"finstagram_posts/new")

end

post '/finstagram_posts' do

  photo_url = params[ :photo_url ]

  # instantiate new FinstagramPost
  @finstagram_post = FinstagramPost.new({photo_url: photo_url, user_id: current_user.id})

  # if @post validates, save
  if @finstagram_post.save
    redirect(to('/'))

  else

    erb(:"finstagram_posts/new")

  end

end


# Handle a GET request for the '/finstagram_posts/:id' path
get '/finstagram_posts/:id' do
  @finstagram_post = FinstagramPost.find_by(id: params[:id])

  if @finstagram_post
    erb(:'finstagram_posts/show')
  else
    halt(404, erb(:'errors/404'))
  end
end

post '/comments' do
  
  text = params[:text]
  finstagram_post_id = params[:finstagram_post_id]

  comment = Comment.new({text: text, finstagram_post_id: finstagram_post_id, user_id: current_user.id})

  comment.save
  
  redirect(back)

end

post "/likes" do

  finstagram_post_id = params[:finstagram_post_id]

  likes = Like.new({ finstagram_post_id: finstagram_post_id, user_id: current_user.id})

  likes.save

  redirect(back)

end

delete '/likes/:id' do

  like = Like.find(params[:id])
  like.destroy

  redirect(back)

end
