require 'rails_helper'

RSpec.describe CallsController, :type => :controller do

	it "should say welcome and create a new call" do
		# Given

		# When
		post :create, params: { 
			'CallSid' =>'12341AD24',
			'From' =>'+33123456789',
			'To' =>'+33523415134',
			'CallStatus' =>'ringing',
			'Direction' =>'inbound'
		}

		# Then
		expect(response.status).to eq(200)
		expect(response.body).to eq('<?xml version="1.0" encoding="UTF-8"?><Response><Say language="fr-FR">Bonjour</Say><Gather numDigits="1" timeout="15"><Say language="fr-FR">Pour appeler votre correspondant, tapez 1. Pour lui laisser un message, tapez 2.</Say></Gather></Response>')
		expect(Call.all.length).to eq(1)
	end

	it "should update existing call and forward call" do
		# Given

		# When
		post :create, params: { 
			'Digits' => '1',
			'CallSid' =>'12341AD24',
			'From' =>'+33123456789',
			'To' =>'+33523415134',
			'CallStatus' =>'in-progress',
			'Direction' =>'inbound'
		}

		# Then
		expect(response.status).to eq(200)
		expect(response.body).to eq('<?xml version="1.0" encoding="UTF-8"?><Response><Say language="fr-FR" voice="alice">J\'appelle votre correspondant</Say><Dial><Number statusCallback="http://test.host/calls/events" statusCallbackEvent="initiated ringing answered completed" statusCallbackMethod="POST">+33770029132</Number></Dial><Say language="fr-FR">L\'appel est terminé. Au revoir.</Say><Hangup/></Response>')
		expect(Call.all.length).to eq(1)
	end

	it "should update existing call and record a voicemail" do
		# Given

		# When
		post :create, params: { 
			'Digits' => '2',
			'CallSid' =>'12341AD24',
			'From' =>'+33123456789',
			'To' =>'+33523415134',
			'CallStatus' =>'in-progress',
			'Direction' =>'inbound'
		}

		# Then
		expect(response.status).to eq(200)
		expect(response.body).to eq('<?xml version="1.0" encoding="UTF-8"?><Response><Say language="fr-FR">Merci de laisser un message après le bip sonore.</Say><Record action="http://test.host/calls/voicemail_recorded" method="POST" recordingStatusCallback="http://test.host/calls/voicemails" recordingStatusCallbackMethod="POST"/><Say language="fr-FR">Aucun message enregistré</Say></Response>')
		expect(Call.all.length).to eq(1)
	end

	it "should save recorded voicemail when call exists" do
		# Given
		Call.create(sid: '12341AD24', from: '0123456789', to: '0987654321', status: 'in-progress')

		# When
		post :voicemails, params: { 
			'CallSid' =>'12341AD24',
			'RecordingUrl' =>'http://myrecord.avi'
		}

		# Then
		expect(response.status).to eq(200)
		calls = Call.all
		expect(calls.length).to eq(1)
		expect(calls[0].record_url).to eq('http://myrecord.avi')
	end

	it "should return 404 when call does not exists" do
		# Given
		# When
		post :voicemails, params: { 
			'CallSid' =>'12341AD24',
			'RecordingUrl' =>'http://myrecord.avi'
		}

		# Then
		expect(response.status).to eq(404)
	end

end

