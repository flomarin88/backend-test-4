class CallsController < ApplicationController
	skip_before_action :verify_authenticity_token

	def index
		calls = Call.all
		render json: calls
	end

	def create
		Call.create_or_update(params)
		render xml: voice_response_success
	end

	def events
		Call.create_or_update(params)
		head :no_content
	end

	def voicemails
		@call = Call.find_or_initialize_by(sid: params['CallSid'])
		@call.record_url = params['RecordingUrl']
		@call.save!
		head :ok
	end

	def voice_response_success
      Twilio::TwiML::VoiceResponse.new do |r|
        case params['Digits']
        when '1'
    		r.say 'J\'appelle votre correspondant', language: 'fr-FR', voice: 'alice'
			r.dial do |dial|
    			dial.number('+33770029132', 
    				status_callback_event: 'initiated ringing answered completed',
    				status_callback: url_for('/calls/events'),
    				status_callback_method: 'POST')
			end
			r.say "L'appel est terminé. Au revoir.", language: 'fr-FR'
			r.hangup
        when '2'
			r.say 'Merci de laisser un message après le bip sonore.', language: 'fr-FR'
			r.record(action: url_for('/calls/voicemail_recorded'),
				method: 'POST',
				recording_status_callback: url_for('/calls/voicemails'),
				recording_status_callback_method: 'POST')
			r.say 'Aucun message enregistré', language: 'fr-FR'
        else
			r.say 'Bonjour', language: 'fr-FR'
			r.gather(timeout: 15, num_digits: 1) do |gather|
				gather.say "Pour appeler votre correspondant, tapez 1. Pour lui laisser un message, tapez 2.", language: 'fr-FR'
			end
        end
      end.to_s
    end

    def voicemail_recorded
    	response = Twilio::TwiML::VoiceResponse.new do |r|
    		r.say 'Message enregistré. Au revoir', language: 'fr-FR'
    		r.hangup
    	end.to_s
    	render xml: response
    end
end