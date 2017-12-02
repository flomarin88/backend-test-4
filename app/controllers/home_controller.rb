class HomeController < ApplicationController
	def index
		response = Twilio::TwiML::VoiceResponse.new do |r|
			r.say 'Hello Monkey'
		end.to_s
		render xml: response
	end
end