class WebhookController < ApplicationController
	
	def index
		response = Twilio::TwiML::VoiceResponse.new do |r|
			r.gather numDigits: 1 do |g|
				g.say('Hello Aircall, You reached Florian\'s phone. Press 1 to talk to him. Press 2 to leave a voicemail.', voice: 'alice')
			end
  		end.to_s
		render xml: response
	end

end