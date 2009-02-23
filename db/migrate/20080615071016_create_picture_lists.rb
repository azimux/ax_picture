class CreatePictureLists < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      create_table :picture_lists do |t|
        t.timestamps
      end
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      drop_table :picture_lists
    end
  end
end
