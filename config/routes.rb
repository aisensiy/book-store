BooksLists::Application.routes.draw do

  captcha_route

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  root :to => 'app2#index'
  match 'mockup/:action' => 'mockup#:action'
  match 'mockup2/:action' => 'mockup2#:action'

  get '/app2' => 'app2#index'

  scope 'api/1' do
    resources :users, defaults: { format: 'json' }, only: [:create] do
      collection do
        delete :signout
        post :signin
        get :current_user
        put :update
        post :password_reset
      end
    end

    resources :images, defaults: { format: 'json' }, only: [:index, :create, :update, :show, :destroy] do
      collection do
        get :own
        get :week_top
        get :month_top
        get :recommend
        get :search
      end
      member do
        post :send_to_device
      end
    end

    resources :books, defaults: { format: 'json' }, only: [:create, :index, :update, :destroy, :show] do
      collection do
        get :own
        get :week_top
        get :month_top
        get :recommend
        get :search
        get :tag
      end
      member do
        post :send_to_device
      end
    end

    get '/:model/:model_id/comments' => 'comments#index'
    post '/:model/:model_id/comments' => 'comments#create'
    delete '/:model/:model_id/comments/:id' => 'comments#destroy'

    post '/upload' => 'upload#post'
    get  '/upload/token' => 'upload#get_token'
    get  '/upload/download_token' => 'upload#get_download_token'
    get '/upload/callback' => 'upload#callback'

    post '/push' => 'push#push'
  end

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
