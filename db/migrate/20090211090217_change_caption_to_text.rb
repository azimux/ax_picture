class ChangeCaptionToText < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      change_column :pictures, :caption, :text
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      change_column :pictures, :caption, :string, :limit => 512
    end
  end
end
