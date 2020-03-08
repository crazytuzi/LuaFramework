local OctetsStream = require("netio.OctetsStream")
local ExpAwardBean = class("ExpAwardBean")
function ExpAwardBean:ctor(expType, num)
  self.expType = expType or nil
  self.num = num or nil
end
function ExpAwardBean:marshal(os)
  os:marshalInt32(self.expType)
  os:marshalInt32(self.num)
end
function ExpAwardBean:unmarshal(os)
  self.expType = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
end
return ExpAwardBean
