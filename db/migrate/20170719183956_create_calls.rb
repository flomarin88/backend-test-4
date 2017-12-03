class CreateCalls < ActiveRecord::Migration[5.1]
  def change
    create_table :calls do |t|
		t.string :sid, null: false, index: true
		t.string :parent_sid
 		t.string :status, null: false
 		t.string :from, null: false
 		t.string :to, null: false
 		t.string :record_url
 		t.string :direction
 		t.integer :duration
 		t.datetime :completed_at
 		t.timestamps
    end
  end
end
