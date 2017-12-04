Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  	resources :calls, param: :sid
  	post '/calls/status', to: 'calls#status'
  	post '/calls/voicemails', to: 'calls#voicemails'
  	post '/calls/voicemail_recorded', to: 'calls#voicemail_recorded'
end
