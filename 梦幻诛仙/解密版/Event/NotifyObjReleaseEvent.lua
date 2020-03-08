local Lplus = require("Lplus")
local NotifyObjReleaseEvent = Lplus.Class("NotifyObjReleaseEvent")
local def = NotifyObjReleaseEvent.define
def.field("string").obj_id = ""
NotifyObjReleaseEvent.Commit()
return NotifyObjReleaseEvent
