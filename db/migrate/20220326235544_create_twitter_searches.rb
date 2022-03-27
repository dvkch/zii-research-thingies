class CreateTwitterSearches < ActiveRecord::Migration[6.1]
  def change
    create_table :twitter_searches do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
