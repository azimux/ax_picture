Rails.application.routes.draw do
#  map.picture "pictures/:id/:dimensions",
#    :controller => 'pictures',
#    :action => 'fetch',
#    :dimensions => nil,
#    :requirements => {
#    :id => /\d+/,
#    :dimensions => /\d+x\d+/
#  }
  match "picture", "pictures/:id(/:dimensions)", :to => "pictures#fetch",
    :id => /\d+/,
    :dimensions => /\d+x\d+/
end