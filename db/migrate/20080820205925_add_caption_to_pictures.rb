class AddCaptionToPictures < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      add_column :pictures, :caption, :string, :limit => 512
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      remove_column :pictures, :caption
    end
  end
end
