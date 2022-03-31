class CreateCachedItems < ActiveRecord::Migration[6.1]
  def change
    create_table :cached_items do |t|
      t.string :key, index: { unique: true }
      t.text :value

      t.timestamps
    end
  end
end
