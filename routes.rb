map.pictures "pictures/:id/:dimensions", 
  :controller => 'pictures',
  :action => 'fetch', 
  :dimensions => nil,
  :requirements => {
  :b64id => /\d+/,
  :dimensions => /\d+x\d+/
}
