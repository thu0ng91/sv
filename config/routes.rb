require 'sidekiq/web'
Rails.application.routes.draw do
  mount Sidekiq::Web, at: '/sidekiq'

  root to: 'novels#index'
  post '/login', to: 'sessions#create'
  get '/login', to: 'sessions#new'
  get '/logout', to: 'sessions#destroy'
  

  resources :novels do 
    collection do
      put 'search'
      put 'update_novel'
      get 'auto_crawl_info'
      put 'auto_crawl'
    end
    member do
      get 'invisiable_articles'
      get 'set_all_articles_to_invisiable'
      put 'set_artlcles_to_invisiable'
      post 'change'
      get 'recrawl_all_articles'
      get 'recrawl_blank_articles'
    end
  end

  resources :articles do
    collection do
      get 're_crawl'
      put 'crawl_text_onther_site'
      put 'reset_num'
      put 'search_by_num'
    end
  end

  resources :ships, except: [:index,:show] do
    collection do
      get 'this_week_hot'
      get 'this_month_hot'
      get 'hot'
    end
  end

  resources :recommend_categories
  resources :recommend_category_novel_ships


  namespace :api do
    get 'status_check' => 'api#status_check'
    get 'version_check' => 'api#version_check'
    namespace :v1 do

      resources :recommend_categories, only: [:index]
      resources :categories, :only => [:index]
      resources :novels,:only => [:index, :show] do
        collection do
          get 'category_hot'
          get 'category_this_week_hot'
          get 'category_recommend'
          get 'category_latest_update'
          get 'category_finish'
          get 'all_novel_update'
          get 'hot'
          get 'this_week_hot'
          get 'this_month_hot'
          get 'search'
          get 'elastic_search'
          get 'classic'
          get 'classic_action'
          get 'collect_novels_info'
          get 'recommend_category_novels'
          get 'new_uploaded_novels'
        end
        member do 
          get 'detail_for_save'
        end
      end
      resources :articles,:only => [:index, :show] do
        collection do 
          get 'next_article'
          get 'previous_article'
          get 'articles_by_num'
          get 'next_article_by_num'
          get 'previous_article_by_num'
          # get 'db_transfer_index'
        end
      end

      resources :users, :only => [:create] do
        collection do
          put 'update_novel'
          get 'get_novels'
          get 'back_up_info'
        end
      end
    end
  end
end
