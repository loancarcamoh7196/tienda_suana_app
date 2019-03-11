class AddImageToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :image, :string, default: '<i class="fas fa-user-astronaut"></i>'
  end
end
