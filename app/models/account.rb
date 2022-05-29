class Account < ApplicationRecord
	after_initialize :defaults
	belongs_to :user
	enum account_type: [:admin, :photographer, :customer]

	private
	def defaults
 		unless persisted?
	    self.account_type = 2
	  end
	end
end
