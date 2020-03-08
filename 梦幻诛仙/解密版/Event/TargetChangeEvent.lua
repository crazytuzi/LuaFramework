local Lplus = require("Lplus")
local TargetChangeEvent = Lplus.Class("TargetChangeEvent")
local def = TargetChangeEvent.define
def.field("string").TargetID = ZeroUInt64
def.field("boolean").AutoSelected = true
TargetChangeEvent.Commit()
return TargetChangeEvent
