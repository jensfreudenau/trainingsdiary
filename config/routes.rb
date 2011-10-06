Trainings1::Application.routes.draw do
  
#  get "courses/edit"
#
#  get "courses/index"
#
#  get "courses/new"
#
#  get "courses/show"
#  get "courses/create_from_activity"

  match "/courses/download", :controller => "courses", :action => "course"
  match "/courses/bigmap", :controller => "courses", :action => "bigmap"
  match "/courses/create_from_activity/:trainings_id", :to => 'courses#create_from_activity'
  match '/home' => "trainings#index", :as => :user_root 
  resources :courses

  devise_for :users
  
  resources :roles
  resources :home
  resources :course_names
  resources :sports
  resources :sport_levels
  resources :trainings
  resources :statistics
  resources :blog_entries
	#resources :users
  devise_scope :user do
    get '/signin' => 'devise/sessions#new'
    get '/logout' => 'devise/sessions#destroy'
  end
  
  
  resources :token_authentications, :only => [:create, :destroy]
  resources :user, :controller => "user"
   
  resources :sport_levels do
    post :sort, :on => :collection
  end
  resources :sports do
    post :sort, :on => :collection
  end
  resources :course_names do
    post :sort, :on => :collection
  end
  resources :trainings do
    post :sort, :on => :collection
  end
  match 'bigmap', :to => 'home#bigmap'
  
=begin
	devise_for :users, :controllers => {:users => "users"}  
		resources :user
	devise_scope :users do
		get '/login' => 'devise/sessions#new'
		get '/logout' => 'devise/sessions#destroy'
	end
=end	
  root :to => "home#index"

# The priority is based upon order of creation:
# first created -> highest priority.

# Sample of regular route:
#   match 'products/:id' => 'catalog#view'
# Keep in mind you can assign values other than :controller and :action

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
# root :to => "welcome#index"

# See how all your routes lay out with "rake routes"

# This is a legacy wild controller route that's not recommended for RESTful applications.
# Note: This route will make all actions in every controller accessible via GET requests.
# match ':controller(/:action(/:id(.:format)))'
end
