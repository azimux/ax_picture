class PictureList < ActiveRecord::Base
  has_many :picture_list_entries, :order => :position

  def pictures
    picture_list_entries.map(&:picture)
  end

  def clone
    retval = super

    retval.picture_list_entries = picture_list_entries.map {|ple|ple.clone}
#    picture_list_entries.each do |ple|
#      ple = ple.clone
#      retval.picture_list_entries << ple
#    end
    
    retval
  end

  def build_ple_map(other_pic_list)
    retval = {}
    
    unless other_pic_list.picture_list_entries.size == picture_list_entries.size
      raise "not similar pic lists" 
    end
    
    0.upto(picture_list_entries.size - 1) do |index|
      unless other_pic_list.picture_list_entries[index] == picture_list_entries[index]
        raise "Not identical picture list entries"
      end
      
      retval[picture_list_entries[index].id] = other_pic_list.picture_list_entries[index].id
    end
    
    retval
  end
end
