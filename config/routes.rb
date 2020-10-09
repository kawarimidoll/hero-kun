Rails.application.routes.draw do
  get 'svg/today', format: :svg
  get 'svg/recent_contrib', format: :svg
end
