class RemoveTwitterSearchSourceKind < ActiveRecord::Migration[6.1]
  def change
    remove_column :twitter_search_sources, :kind, :string, null: false, default: 'user'
  end
end
