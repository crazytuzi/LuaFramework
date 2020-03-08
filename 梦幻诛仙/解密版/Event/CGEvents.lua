local Lplus = require("Lplus")
local CGFinishEvent = Lplus.Class("Event.CGEvents.CGFinishEvent")
do
  local def = CGFinishEvent.define
  def.field("number").cgId = 0
  def.static("number", "=>", CGFinishEvent).new = function(cgId)
    local obj = CGFinishEvent()
    obj.cgId = cgId
    return obj
  end
end
CGFinishEvent.Commit()
return {CGFinishEvent = CGFinishEvent}
