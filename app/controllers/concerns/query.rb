module Query
  extend ActiveSupport::Concern
  included do
    def index
      where = {"is_public" => true}
      query_with_where(where)
    end

    def search
      where = {'$or' => [{'title' => {'$regex' => params[:q]}}]}
      query_with_where(where)
    end

    def tag
      where = {"tags" => params[:tag]}
      query_with_where(where)
    end
  end
end
