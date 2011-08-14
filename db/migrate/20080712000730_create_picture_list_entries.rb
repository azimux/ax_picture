class CreatePictureListEntries < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      create_table :picture_list_entries do |t|
        t.integer :picture_id, :null => false
        t.column :position, :smallint
        t.integer :picture_list_id, :null => false

        t.timestamps
      end

      if !Rails.auto_indexing_enabled?
        add_index :picture_list_entries, :picture_list_id
        add_index :picture_list_entries, :picture_id
      end
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      drop_table :picture_list_entries
    end
  end
end
