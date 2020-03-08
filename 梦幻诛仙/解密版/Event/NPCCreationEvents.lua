local Lplus = require("Lplus")
local NPCCreateEvent = Lplus.Class("Event.NPCCreationEvents.NPCCreateEvent")
do
  local def = NPCCreateEvent.define
  local ECNPC = Lplus.ForwardDeclare("ECNPC")
  def.field(ECNPC).npc = nil
  def.final(ECNPC, "=>", NPCCreateEvent).new = function(npc)
    local obj = NPCCreateEvent()
    obj.npc = npc
    return obj
  end
end
NPCCreateEvent.Commit()
local NPCPreDestroyEvent = Lplus.Class("Event.NPCCreationEvents.NPCPreDestroyEvent")
do
  local def = NPCPreDestroyEvent.define
  local ECNPC = Lplus.ForwardDeclare("ECNPC")
  def.field(ECNPC).npc = nil
  def.final(ECNPC, "=>", NPCPreDestroyEvent).new = function(npc)
    local obj = NPCPreDestroyEvent()
    obj.npc = npc
    return obj
  end
end
NPCPreDestroyEvent.Commit()
local NPCCreationEvents = {NPCCreateEvent = NPCCreateEvent, NPCPreDestroyEvent = NPCPreDestroyEvent}
return NPCCreationEvents
