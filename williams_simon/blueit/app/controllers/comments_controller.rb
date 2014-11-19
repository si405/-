class CommentsController < ApplicationController
	before_filter :authenticate_user!, :only => [:new, :create, :edit, :destroy]

# Create a new comment
def create
    @post = Post.find(params[:post_id])
    @comment = @post.comments.new(comment_params)
    if @comment.save
			flash[:success] = "Comment created"
			redirect_to posts_path 
		else
			flash[:error] = "Unable to save post. Please try again"
			render :create
		end

    redirect_to post_path(@post)
  end
 
  private
    def comment_params
      params.require(:comment).permit(:commenter, :body)
    end

end
