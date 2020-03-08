local OctetsStream = require("netio.OctetsStream")
local Statistic = class("Statistic")
function Statistic:ctor(right, wrong)
  self.right = right or nil
  self.wrong = wrong or nil
end
function Statistic:marshal(os)
  os:marshalInt32(self.right)
  os:marshalInt32(self.wrong)
end
function Statistic:unmarshal(os)
  self.right = os:unmarshalInt32()
  self.wrong = os:unmarshalInt32()
end
return Statistic
