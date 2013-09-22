class ImagesController < ApplicationController
  include AppHelper
  respond_to :json

  before_filter do
    @ImageClient = Klass.new('Image')
  end

  include Query

  def month_top
    cur_month = Time.now.strftime('%Y %m')
    logger.debug "===== #{cur_month} ====="
    images = @ImageClient.range_top('month', cur_month, params[:limit] || 10)
    render status: 200, json: images
  end

  def week_top
    cur_week = Time.now.strftime('%Y %W')
    images = @ImageClient.range_top('week', cur_week, params[:limit] || 10)
    render status: 200, json: images
  end

  def recommend
    images = Parse::Query.new('Image').tap do |q|
      q.greater_than 'priority', 0
      q.or(Parse::Query.new('Image').tap do |or_query|
        or_query.eq('objectId', {
          '$select' => {
            'query' => {
              'className' => 'DownloadRecord',
              'where' => {
                'range' => '',
                'range_type' => 'total',
                'type' => 'image'
              }
            },
            'key' => 'item_id',
            'order_by' => '-count',
            'limit' => params[:limit]
          }
        })
      end)
      q.order_by = '-priority,-count'
      q.limit = params[:limit]
    end.get

    render status: 200, json: images
  end

  def show
    resp = @ImageClient.get(params[:id])
    write_authority(resp.parsed_response)
    render status: resp.code, json: resp
  end

  def own
    resp = @ImageClient.query(params[:limit], params[:skip], where: {'user_id' => session[:user_id]})
    render status: resp.code, json: resp
  end

  def create
    params[:image][:user_id] = session[:user_id]
    resp = @ImageClient.create(session[:user_id], params[:image])

    if resp.code == 201
      render status: 201, json: {objectId: resp['objectId']}
    else
      render status: resp.code, json: resp.body
    end
  end

  def update
    resp = @ImageClient.update(params[:id], session[:token], image_params)
    render status: resp.code, json: resp.body
  end

  def destroy
    @ImageClient.destroy(params[:id], session[:token])
    @ImageClient.delete_file(params[:file_key])
    render status: 200, json: {}
  end

  def send_to_device
    user = User.get_user(session[:user_id]).parsed_response
    resp = Push.send_url_to_user_device(user, 'image', params[:id])
    render status: resp.code, json: resp
  end

  private
  def image_params
    params.require(:image).permit(:is_public, :priority, :rate, :rating, :title, :tags => [])
  end

  def query_with_where(where)
    resp = @ImageClient.query(params[:limit], params[:skip], where: where)
    process_authorities(resp.parsed_response['results'])
    render status: resp.code, json: resp
  end
end
