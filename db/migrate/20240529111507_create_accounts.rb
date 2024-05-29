class CreateAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :account, id: :serial do |t|
      t.string :auth_id, limit: 40
      t.string :username, limit: 30
    end
  end
end
