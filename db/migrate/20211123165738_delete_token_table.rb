class DeleteTokenTable < ActiveRecord::Migration[6.1]
  def change
    drop_table :tokens
  end
end
