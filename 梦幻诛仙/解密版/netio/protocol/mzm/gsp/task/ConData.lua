local OctetsStream = require("netio.OctetsStream")
local ConData = class("ConData")
function ConData:ctor(conId, param, subParam)
  self.conId = conId or nil
  self.param = param or nil
  self.subParam = subParam or nil
end
function ConData:marshal(os)
  os:marshalInt32(self.conId)
  os:marshalInt64(self.param)
  os:marshalString(self.subParam)
end
function ConData:unmarshal(os)
  self.conId = os:unmarshalInt32()
  self.param = os:unmarshalInt64()
  self.subParam = os:unmarshalString()
end
return ConData
