Rails.application.routes.draw do
  get '/plaid_items/new' => 'plaid_items#new', as: 'new_plaid_item'
  post '/plaid_items' => 'plaid_items#create', as: 'plaid_items'
  post '/transactions/import' => 'transactions#import', as: 'import_transactions'
  get '/' => 'transactions#index', as: 'transactions'
end
