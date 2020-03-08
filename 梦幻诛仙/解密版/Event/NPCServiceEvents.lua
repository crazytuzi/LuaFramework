local Lplus = require("Lplus")
local EmptyClass = require("Utility.EmptyClass")
local NPCServiceBeginEvent = Lplus.Class("NPCServiceEvents.NPCServiceBeginEvent")
do
  local def = NPCServiceBeginEvent.define
  def.field("string").objectId = ZeroUInt64
  def.static("string", "=>", NPCServiceBeginEvent).new = function(objectId)
    local obj = NPCServiceBeginEvent()
    obj.objectId = objectId
    return obj
  end
end
NPCServiceBeginEvent.Commit()
local NPCServiceEndEvent = EmptyClass.Make("NPCServiceEvents.NPCServiceEndEvent")
return {NPCServiceBeginEvent = NPCServiceBeginEvent, NPCServiceEndEvent = NPCServiceEndEvent}
