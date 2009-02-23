class CreateBinaryFiles < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      create_table :binary_files do |t|
        t.binary :data, :null => false

        t.timestamps
      end

      add_column :pictures, :binary_file_id, :integer

      Picture.find(:all).each do |picture|
        b = BinaryFile.create(:data => picture.read_attribute(:file_data))
        picture.binary_file_id = b.id
        picture.save!
      end

      change_column_null :pictures, :binary_file_id, false

      remove_column :pictures, :file_data
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      add_column :pictures, :file_data, :binary

      BinaryFile.find(:all).each do |file|
        pictures = Picture.find_all_by_binary_file_id(file.id) || []
        pictures.each do |picture|
          picture.file_data = file.data
          picture.save!
        end
      end

      remove_column :pictures, :binary_file_id

      drop_table :binary_files
    end
  end
end
