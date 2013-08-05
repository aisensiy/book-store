class CommentsController < ApplicationController
  include AppHelper
  before_filter :signin?, only: [:destory, :create]

  def index
    comment_query = Parse::Query.new("Comment").tap do |q|
      q.eq('book', Parse::Pointer.new({
        'className' => 'Book',
        'objectId' => params[:book_id]
      }))
    end
    comment_query.include = 'user'
    comments = comment_query.get
    process_authorities(comments)
    render json: comments
  end

  def create
    @comment = Parse::Object.new('Comment', comment_params)
    @comment['book'] = {'__type' => 'Pointer', 'className' => 'Book', 'objectId' => params[:book_id]}
    @comment['user'] = {'__type' => 'Pointer', 'className' => '_User', 'objectId' => session[:user_id]}
    @comment[:ACL] = {
      "*" => {
        "read" => true
      },
      "role:Admins" => {
        "write" => true
      },
      session[:user_id] => {
        "write" => true
      }
    }
    @comment.save

    render json: @comment, status: 201
  end

  def destory
    @commemt = Parse::Query.new('Comment').eq('objectId', params[:id]).eq('user_id', session[:user_id]).get.first
    if @comment.nil?
      render status: 404, json: @comment
    else
      @comment.parse_delete
      render status: 200, json: @comment
    end
  end

  private
  def comment_params
    params.require(:comment).permit(:content)
  end
end
