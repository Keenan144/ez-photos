class Admin < ApplicationRecord
	belongs_to :account
  
  # the authenticate method from devise documentation
  def self.check_admin
    admin = Admin.find_one(user_id: current_user.id)
  end
end
