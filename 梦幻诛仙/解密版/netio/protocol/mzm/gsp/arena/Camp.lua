local OctetsStream = require("netio.OctetsStream")
local Camp = class("Camp")
function Camp:ctor(camp, score)
  self.camp = camp or nil
  self.score = score or nil
end
function Camp:marshal(os)
  os:marshalInt32(self.camp)
  os:marshalInt32(self.score)
end
function Camp:unmarshal(os)
  self.camp = os:unmarshalInt32()
  self.score = os:unmarshalInt32()
end
return Camp
