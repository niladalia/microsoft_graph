class AddRefreshToken < ActiveRecord::Migration[6.1]
  def change
    add_column :tokens, :refresh_token, :string  
  end
end
