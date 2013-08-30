class ImagesController < ApplicationController
  respond_to :json

  before_filter do
    @ImageClient = Klas.new('Image')
  end

  def index
    resp = @ImageClient.query(params[:limit], params[:skip], where: {'is_public' => true})
    process_authorities(resp.parsed_response['results'])
    render status: resp.code, json: resp
  end

  def show
    resp = @ImageClient.get(params[:id])
    write_authority(resp.parsed_response)
    render status: resp.code, json: resp
  end

  def create
    image = Parse::Object.new 'Image', params[:image]
    image.save

    render json: image
  end

  def update
    begin
      resp = @ImageClient.update(params[:id], session[:token], image_params)
      render status: resp.code, json: resp.body
    rescue Exception => e
      render 403, json: e
    end
  end

  def destroy
    @ImageClient.destroy(params[:id], session[:token])
    @ImageClient.delete_file(file_key)
    render status: 200, json: {}
  end

  private
  def image_params
  end
end
