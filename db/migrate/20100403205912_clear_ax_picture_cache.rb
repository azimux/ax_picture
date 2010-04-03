class ClearAxPictureCache < ActiveRecord::Migration
  def self.up
    Picture.clear_cache
  end

  def self.down
  end
end
