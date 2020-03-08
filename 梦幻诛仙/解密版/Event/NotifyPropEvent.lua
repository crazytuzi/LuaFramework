local Lplus = require("Lplus")
local NotifyPropEvent = Lplus.Class("NotifyPropEvent")
local def = NotifyPropEvent.define
def.field("string").obj_id = ""
NotifyPropEvent.Commit()
return NotifyPropEvent
