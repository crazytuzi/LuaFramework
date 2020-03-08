local Lplus = require("Lplus")
local ArenaUpdateEvent = Lplus.Class("ArenaUpdateEvent.ArenaUpdateEvent")
do
  local def = ArenaUpdateEvent.define
  def.static("=>", ArenaUpdateEvent).new = function()
    local obj = ArenaUpdateEvent()
    return obj
  end
end
ArenaUpdateEvent.Commit()
local ArenaPlayersEvent = Lplus.Class("ArenaUpdateEvent.ArenaPlayersEvent")
do
  local def = ArenaPlayersEvent.define
  def.static("=>", ArenaPlayersEvent).new = function()
    local obj = ArenaPlayersEvent()
    return obj
  end
end
ArenaPlayersEvent.Commit()
local ArenaRanksEvent = Lplus.Class("ArenaUpdateEvent.ArenaRanksEvent")
do
  local def = ArenaRanksEvent.define
  def.static("=>", ArenaRanksEvent).new = function()
    local obj = ArenaRanksEvent()
    return obj
  end
end
ArenaRanksEvent.Commit()
local ArenaResultEvent = Lplus.Class("ArenaUpdateEvent.ArenaResultEvent")
do
  local def = ArenaResultEvent.define
  def.field("number").result = 0
  def.field("number").rank = 0
  def.static("=>", ArenaResultEvent).new = function()
    local obj = ArenaResultEvent()
    return obj
  end
end
ArenaResultEvent.Commit()
return {
  ArenaUpdateEvent = ArenaUpdateEvent,
  ArenaPlayersEvent = ArenaPlayersEvent,
  ArenaRanksEvent = ArenaRanksEvent,
  ArenaResultEvent = ArenaResultEvent
}
