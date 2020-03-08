local Lplus = require("Lplus")
local SceneChangeEvent = Lplus.Class("Event.SceneChangeEvent")
do
  local def = SceneChangeEvent.define
  def.field("number").new_scene_id = 0
  def.final("number", "=>", SceneChangeEvent).new = function(new_scene_id)
    local obj = SceneChangeEvent()
    obj.new_scene_id = new_scene_id
    return obj
  end
end
return SceneChangeEvent.Commit()
