class Call < ApplicationRecord
	validates :sid, :status, :from, :to, presence: true

	def self.create_or_update(params)
		call = Call.find_or_initialize_by(sid: params['CallSid'])
		call.assign_attributes({
			sid: params['CallSid'],
			parent_sid: params['ParentCallSid'],
			from: params['From'],
			to: params['To'],
			status: params['CallStatus'],
			direction: params['Direction'],
			duration: params['CallDuration']
		})
		if call.status == 'completed'
			call.completed_at = Time.zone.now
		end
		call.save!
		call
	end

end
