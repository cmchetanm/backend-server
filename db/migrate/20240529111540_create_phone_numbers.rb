class CreatePhoneNumbers < ActiveRecord::Migration[5.2]
  def change
    create_table :phone_number, id: :serial do |t|
      t.string :number, limit: 40
      t.integer :account_id
    end
  end
end
