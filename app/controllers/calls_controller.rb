class CallsController < ApplicationController
	skip_before_action :verify_authenticity_token

	def index
		calls = Call.all
		render json: calls
	end

	def create
		Call.create_or_update(params)
		case params['Digits']
        when '1'
    		message = forward_call_message
        when '2'
			message = leave_a_voicemail_message
        else
			message = welcome_message
        end
		render xml: message
	end

	def events
		Call.create_or_update(params)
		head :no_content
	end

	def voicemails
		call = Call.find_or_initialize_by(sid: params['CallSid'])
		call.record_url = params['RecordingUrl']
		call.save!
		head :ok
	end

    def voicemail_recorded
    	response = Twilio::TwiML::VoiceResponse.new do |r|
    		r.say 'Message enregistré. Au revoir', language: 'fr-FR'
    		r.hangup
    	end.to_s
    	render xml: response
    end

    def welcome_message
    	Twilio::TwiML::VoiceResponse.new do |r|
	    	r.say 'Bonjour', language: 'fr-FR'
			r.gather(timeout: 15, num_digits: 1) do |gather|
				gather.say "Pour appeler votre correspondant, tapez 1. Pour lui laisser un message, tapez 2.", language: 'fr-FR'
			end
		end.to_s
    end

	def forward_call_message
		Twilio::TwiML::VoiceResponse.new do |r|
			r.say 'J\'appelle votre correspondant', language: 'fr-FR', voice: 'alice'
			r.dial do |dial|
				dial.number('+33770029132', 
					status_callback_event: 'initiated ringing answered completed',
					status_callback: calls_events_url,
					status_callback_method: 'POST')
			end
			r.say 'L\'appel est terminé. Au revoir.', language: 'fr-FR'
			r.hangup
		end.to_s
    end

    def leave_a_voicemail_message
		Twilio::TwiML::VoiceResponse.new do |r|
    		r.say 'Merci de laisser un message après le bip sonore.', language: 'fr-FR'
			r.record(action: calls_voicemail_recorded_url,
				method: 'POST',
				recording_status_callback: calls_voicemails_url,
				recording_status_callback_method: 'POST')
			r.say 'Aucun message enregistré', language: 'fr-FR'
		end.to_s
    end

end