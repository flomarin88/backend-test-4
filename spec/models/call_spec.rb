require 'rails_helper'

RSpec.describe Call, :type => :model do
  
	subject {
	    described_class.new(sid: '1234', status: 'ringing', from: '+33123456789', to: '++3198765432')
	  }

	it "is valid with valid attributes" do
  		expect(subject).to be_valid
	end

	it "is not valid without sid" do
		subject.sid = nil
  		expect(subject).not_to be_valid
	end

	it "is not valid without status" do
		subject.status = nil
  		expect(subject).not_to be_valid
	end

	it "is not valid without from" do
		subject.from = nil
  		expect(subject).not_to be_valid
	end

	it "is not valid without to" do
		subject.to = nil
  		expect(subject).not_to be_valid
	end

	it "should create a call when does not exist" do
		params = {
			'CallSid' =>'12341AD24',
			'ParentCallSid' =>'parent_sid',
			'From' =>'+33123456789',
			'To' =>'+33523415134',
			'CallStatus' =>'ringing',
			'Direction' =>'inbound',
			'CallDuration' =>'35'
		}
		
		call = Call.create_or_update(params)
		expect(call.sid).to eq('12341AD24')
		expect(call.parent_sid).to eq('parent_sid')
		expect(call.from).to eq('+33123456789')
		expect(call.to).to eq('+33523415134')
		expect(call.status).to eq('ringing')
		expect(call.direction).to eq('inbound')
		expect(call.duration).to eq(35)
		expect(call.completed_at).to be_nil
	end

	it "should set completed_at with now when status is completed" do
		params = {
			'CallSid' =>'12341AD24',
			'ParentCallSid' =>'parent_sid',
			'From' =>'+33123456789',
			'To' =>'+33523415134',
			'CallStatus' =>'completed',
			'Direction' =>'inbound',
			'CallDuration' =>'35'
		}
		
		call = Call.create_or_update(params)
		expect(call.completed_at).not_to be_nil
	end

	it "should update call when exists" do
		# Given
		subject.save
		expect(Call.all.length).to eq(1)
		
		params = {
			'CallSid' =>'1234',
			'ParentCallSid' =>'parent_sid',
			'From' =>'+33123456789',
			'To' =>'+33523415134',
			'CallStatus' =>'completed',
			'Direction' =>'inbound',
			'CallDuration' =>'70'
		}
		
		# When
		call = Call.create_or_update(params)

		# Then
		expect(Call.all.length).to eq(1)
		expect(call.status).to eq('completed')
		expect(call.duration).to eq(70)
	end
end