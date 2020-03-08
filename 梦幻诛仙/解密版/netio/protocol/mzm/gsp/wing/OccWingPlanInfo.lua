local OctetsStream = require("netio.OctetsStream")
local OccWingPlanInfo = class("OccWingPlanInfo")
function OccWingPlanInfo:ctor(occId, planName)
  self.occId = occId or nil
  self.planName = planName or nil
end
function OccWingPlanInfo:marshal(os)
  os:marshalInt32(self.occId)
  os:marshalOctets(self.planName)
end
function OccWingPlanInfo:unmarshal(os)
  self.occId = os:unmarshalInt32()
  self.planName = os:unmarshalOctets()
end
return OccWingPlanInfo
