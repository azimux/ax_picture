class PictureListEntry < ActiveRecord::Base
  belongs_to :picture
  belongs_to :picture_list
  acts_as_list :scope => :picture_list_id

  def clone
    retval = super

    retval.picture = picture.clone

    retval
  end

  def == other
    return true if other.id == id
    
    return false if picture != other.picture

    exclude = [:id, :created_at, :updated_at, :picture_list_id, :picture_id]

    me = attributes.dup
    exclude.each do |att|
      me.delete att
      me.delete att.to_s
    end

    them = other.attributes.dup

    exclude.each do |att|
      them.delete att
      them.delete att.to_s
    end

    me == them
  end
end
