require 'ax_picture/ext/action_controller/base.rb'

class BadImageURL < Exception
end

ActionView::Base.class_eval {include(PicturesHelper)}
ActionController::Base.class_eval {include(Azimux::Picture::ActionController::Base)}