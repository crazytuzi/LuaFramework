local Lplus = require("Lplus")
local CGFinishEvent = Lplus.Class("Event.ClientEvents.CGFinishEvent")
do
  local def = CGFinishEvent.define
  def.field("number").event_type = 0
  def.field("number").pre = 0
  def.static("number", "number", "=>", CGFinishEvent).new = function(event_type, pre)
    local obj = CGFinishEvent()
    obj.event_type = event_type
    obj.pre = pre
    return obj
  end
end
CGFinishEvent.Commit()
local EnterSceneEvent = Lplus.Class("Event.ClientEvents.EnterSceneEvent")
do
  local def = EnterSceneEvent.define
  def.field("number").event_type = 0
  def.field("number").pre = 0
  def.static("number", "number", "=>", EnterSceneEvent).new = function(event_type, pre)
    local obj = EnterSceneEvent()
    obj.event_type = event_type
    obj.pre = pre
    return obj
  end
end
EnterSceneEvent.Commit()
return {CGFinishEvent = CGFinishEvent, EnterSceneEvent = EnterSceneEvent}
