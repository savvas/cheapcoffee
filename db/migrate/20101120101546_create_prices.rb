class CreatePrices < ActiveRecord::Migration
  def self.up
    create_table :prices do |t|
      
      t.integer :cafeteria_id
      t.integer :user_id
      
      # map to coffees with a hash
      t.float :price_1
      t.float :price_2
      t.float :price_2
      t.float :price_3
      t.float :price_4
      t.float :price_5
      t.float :price_6

      t.timestamps
    end
    
    add_index :prices, :cafeteria_id
    
  end

  def self.down
    drop_table :prices
  end
end
