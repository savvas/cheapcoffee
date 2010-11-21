class CreateCafeterias < ActiveRecord::Migration
  def self.up
    create_table :cafeterias do |t|
      t.string :name, :length => 30
      t.string :address, :length => 30
      t.string :city, :length => 30
      t.float :lat
      t.float :lng
      t.integer :user_id
      t.integer :likes
      t.string :telephone, :length => 14
      t.string :website, :length => 50

      # map to coffees with a hash
      t.float :price_1, :default => 0
      t.integer :votes_1, :default => 0
      t.float :price_2, :default => 0
      t.integer :votes_2, :default => 0
      t.float :price_2, :default => 0
      t.integer :votes_2, :default => 0
      t.float :price_3, :default => 0
      t.integer :votes_3, :default => 0
      t.float :price_4, :default => 0
      t.integer :votes_4, :default => 0
      t.float :price_5, :default => 0
      t.integer :votes_5, :default => 0
      t.float :price_6, :default => 0
      t.integer :votes_6, :default => 0



      t.timestamps
    end

    add_index :cafeterias, :name
    add_index :cafeterias, :lat
    add_index :cafeterias, :lng
    add_index :cafeterias, :price_1
    add_index :cafeterias, :price_2
    add_index :cafeterias, :price_3
    add_index :cafeterias, :price_4
    add_index :cafeterias, :price_5
    add_index :cafeterias, :price_6

  end

  def self.down
    drop_table :cafeterias
  end
end

