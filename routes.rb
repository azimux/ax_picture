map.picture "pictures/:id/:dimensions", 
  :controller => 'pictures',
  :action => 'fetch', 
  :dimensions => nil,
  :requirements => {
  :id => /\d+/,
  :dimensions => /\d+x\d+/
}
