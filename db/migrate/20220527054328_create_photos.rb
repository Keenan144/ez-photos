class CreatePhotos < ActiveRecord::Migration[7.0]
  def change
    create_table :photos do |t|
    	t.string :title
    	t.string :signed_url
    	t.string :bucket
    	t.string :key
    	t.datetime :expires_at
      t.integer :user_id

      t.timestamps
    end
  end
end
