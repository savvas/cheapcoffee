class CreateSuggestedPrices < ActiveRecord::Migration
  def self.up
    create_table :suggested_prices do |t|
      t.integer   :user_id
      t.integer   :cafeteria_id
      t.string    :product
      t.decimal   :price, :precision => 5, :scale => 2
      
      t.timestamps
    end
  end

  def self.down
    drop_table :suggested_prices
  end
end
