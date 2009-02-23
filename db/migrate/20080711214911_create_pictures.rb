class CreatePictures < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      
      
      create_table :pictures do |t|
        t.binary :file_data, :null => false
        t.integer :file_size, :null => false
        t.string :name, :null => false
        t.string :content_type, :null => false

        t.timestamps
      end
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      drop_table :pictures
    end
  end
end
