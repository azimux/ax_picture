require 'ax_picture/ext/action_controller/base.rb'

ActionView::Base.class_eval {include(PicturesHelper)}
ActionController::Base.class_eval {include(Azimux::Picture::ActionController::Base)}

class << Rails
  if !Rails.methods.include?(:auto_indexing_enabled?)
    def auto_indexing_enabled?
      Gem.loaded_specs.keys.include? 'schema_plus'
    end
  end
end