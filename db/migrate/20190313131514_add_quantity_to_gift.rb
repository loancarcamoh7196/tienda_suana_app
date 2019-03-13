class AddQuantityToGift < ActiveRecord::Migration[5.2]
  def change
    add_column :gifts, :quantity, :integer
  end
end
