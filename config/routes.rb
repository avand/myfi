Rails.application.routes.draw do
  post '/plaid_items' => 'plaid_items#create', as: 'plaid_items'
  post '/transactions/import' => 'transactions#import', as: 'import_transactions'
  patch '/transactions/:id' => 'transactions#update', as: 'transaction'
  get '/transactions' => 'transactions#index', as: 'transactions'
  get '/accounts' => 'accounts#index', as: 'accounts'
  get '/accounts/:id/edit' => 'accounts#edit', as: 'edit_account'
  patch '/accounts/:id' => 'accounts#update', as: 'account'
  get '/' => 'transactions#summary', as: 'summary'
end
