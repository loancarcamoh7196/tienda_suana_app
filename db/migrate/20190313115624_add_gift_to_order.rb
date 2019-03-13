class AddGiftToOrder < ActiveRecord::Migration[5.2]
  def change
    add_reference :orders, :gift, foreign_key: true
  end
end
