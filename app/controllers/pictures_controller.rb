
class PicturesController < ActionController::Base
  def fetch
    picture = Picture.find(params[:id])
    
    send_data(picture.data(params[:dimensions]),
      :filename => picture.name,
      :type => picture.content_type,
      :disposition => 'inline')
  end
    
  
end
