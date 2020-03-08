local Lplus = require("Lplus")
local ECIvtrItem = Lplus.ForwardDeclare("ECIvtrItem")
local IncItemEvent = Lplus.Class("IvtrEvents.IncItemEvent")
do
  local def = IncItemEvent.define
  def.field("number").pack = -1
  def.field("number").slot = 0
  def.field(ECIvtrItem).item = nil
  def.field("number").count = 0
  def.static("number", "number", ECIvtrItem, "number", "=>", IncItemEvent).new = function(pack, slot, item, count)
    local obj = IncItemEvent()
    obj.pack = pack
    obj.slot = slot
    obj.item = item
    obj.count = count
    return obj
  end
end
IncItemEvent.Commit()
local DecItemEvent = Lplus.Class("IvtrEvents.DecItemEvent")
do
  local def = DecItemEvent.define
  def.field("number").pack = -1
  def.field("number").slot = 0
  def.static("number", "number", "=>", DecItemEvent).new = function(pack, slot)
    local obj = DecItemEvent()
    obj.pack = pack
    obj.slot = slot
    return obj
  end
end
DecItemEvent.Commit()
return {IncItemEvent = IncItemEvent, DecItemEvent = DecItemEvent}
