class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts do |t|
    	t.integer :user_id

    	t.string :first_name
    	t.string :last_name
    	t.string :phone
    	t.string :mobile

    	t.string :street_address
    	t.string :city
    	t.string :state
    	t.string :zip

    	t.string :website
    	t.string :twitter
    	t.string :instagram
    	t.string :facebook
    	t.string :tiktok

    	t.string :profile_pic_url

    	t.integer :account_type

      t.timestamps
    end
  end
end
