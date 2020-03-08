local OctetsStream = require("netio.OctetsStream")
local LostExpInfo = class("LostExpInfo")
function LostExpInfo:ctor(totalValue, alreadyGetValue, canGetValue, alreadyGetExp)
  self.totalValue = totalValue or nil
  self.alreadyGetValue = alreadyGetValue or nil
  self.canGetValue = canGetValue or nil
  self.alreadyGetExp = alreadyGetExp or nil
end
function LostExpInfo:marshal(os)
  os:marshalInt32(self.totalValue)
  os:marshalInt32(self.alreadyGetValue)
  os:marshalInt32(self.canGetValue)
  os:marshalInt32(self.alreadyGetExp)
end
function LostExpInfo:unmarshal(os)
  self.totalValue = os:unmarshalInt32()
  self.alreadyGetValue = os:unmarshalInt32()
  self.canGetValue = os:unmarshalInt32()
  self.alreadyGetExp = os:unmarshalInt32()
end
return LostExpInfo
