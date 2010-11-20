class CreateCafeterias < ActiveRecord::Migration
  def self.up
    create_table :cafeterias do |t|
      t.string :name
      t.string :address
      t.string :city
      t.float :lat
      t.float :lng
      t.integer :user_id
      t.integer :likes
      t.integer :pageviews

      # map to coffees with a hash
      t.float :price_1
      t.integer :votes_1
      t.float :price_2
      t.integer :votes_2
      t.float :price_2
      t.integer :votes_2
      t.float :price_3
      t.integer :votes_3
      t.float :price_4
      t.integer :votes_4
      t.float :price_5
      t.integer :votes_5
      t.float :price_6
      t.integer :votes_6


      t.timestamps
    end

    add_index :cafeterias, :name
    add_index :cafeterias, :lat
    add_index :cafeterias, :lng
  end

  def self.down
    drop_table :cafeterias
  end
end

