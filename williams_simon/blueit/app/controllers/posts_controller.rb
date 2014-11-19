class PostsController < ApplicationController
	before_filter :authenticate_user!, :only => [:new, :create, :edit, :destroy]

	# Set @posts to contain all the saved posts in descending vote
	# count order
	def index
		@posts = Post.all.order(created_at: :desc)
	end

	# Instantiate a new empty post object
	def new
		@post = Post.new
	end

	# Create a new post using the params provided from 
	# the view and redirect back to the main index page
	def create
		@post = Post.new(post_params)
		@post.user_id = current_user.id
		if @post.save
			flash[:success] = "Post created"
			redirect_to posts_path 
		else
			flash[:error] = "Unable to save post. Please try again"
			render :create
		end
	end

	# Params contains the data being passed back from the view
	def edit
		@post = Post.find(params[:id])
	end

	# Update the modified post and redirect back to main index
	# Due to the lack of state we first need to relocate the 
	# selected post and then perform the update
	def update
		@post = Post.find(params[:id])
		@post.update(post_params)
		redirect_to posts_path
	end

	# Show all saved posts
	def show
		@post = Post.find(params[:id])
	end

	# Delete the seleected post and redirect back to the 
	# list of posts
	def destroy
		@post = Post.find(params[:id])
		@post.destroy
		redirect_to posts_path
	end

	private

	def post_params
		params.require(:post).permit(:post_title, :post_url, :user_id)
	end


end
