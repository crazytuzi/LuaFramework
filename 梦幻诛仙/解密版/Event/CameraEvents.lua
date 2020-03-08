local Lplus = require("Lplus")
local CameraManualOpEvent = Lplus.Class("CameraEvents.CameraManualOpEvent")
do
  local def = CameraManualOpEvent.define
  def.field("boolean").bMove = false
  def.field("boolean").bYaw = false
  def.field("boolean").bPitch = false
  def.static("boolean", "boolean", "boolean", "=>", CameraManualOpEvent).new = function(bMove, bYaw, bPitch)
    local obj = CameraManualOpEvent()
    obj.bMove = bMove
    obj.bYaw = bYaw
    obj.bPitch = bPitch
    return obj
  end
end
CameraManualOpEvent.Commit()
local CameraEvents = {CameraManualOpEvent = CameraManualOpEvent}
return CameraEvents
