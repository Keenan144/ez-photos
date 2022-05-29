class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts do |t|
    	t.integer :user_id

    	t.string :first_name
    	t.string :last_name

    	t.integer :account_type

      t.timestamps
    end
  end
end
