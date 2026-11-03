resources :issues, only: [] do
  resources :issue_comments, only: [:create]
end
resources :issue_comments, only: [:update, :destroy]
