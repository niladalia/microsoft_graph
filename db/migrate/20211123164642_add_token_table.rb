class AddTokenTable < ActiveRecord::Migration[6.1]
  def change
    create_table :tokens do |t|
      t.string :token, :null => false
      t.timestamps
    end

  end
end




  