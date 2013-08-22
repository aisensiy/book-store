class ImagesController < ApplicationController
  respond_to :json

  def index
    @images = Parse::Query.new('Image').tap do |q|
      q.limit = params[:limit]
      q.skip  = params[:skip]
    end.get

    respond_with @images
  end

  def show
  end

  def create
    image = Parse::Object.new 'Image', params[:image]
    image.save

    render json: image
  end

  def update
  end

  def destroy
  end

  private
  def image_params
  end
end
