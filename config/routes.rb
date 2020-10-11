Rails.application.routes.draw do
  get 'svg/today', format: :svg
  # username regexp: https://github.com/shinnn/github-username-regex
  get 'svg/recent_contrib/:username', to: 'svg#recent_contrib', username: /[a-z\d]([a-z\d]|-[a-z\d]){0,38}/
end
