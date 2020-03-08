local OctetsStream = require("netio.OctetsStream")
local MoneyAwardBean = class("MoneyAwardBean")
function MoneyAwardBean:ctor(bigType, littleType, num)
  self.bigType = bigType or nil
  self.littleType = littleType or nil
  self.num = num or nil
end
function MoneyAwardBean:marshal(os)
  os:marshalInt32(self.bigType)
  os:marshalInt32(self.littleType)
  os:marshalInt64(self.num)
end
function MoneyAwardBean:unmarshal(os)
  self.bigType = os:unmarshalInt32()
  self.littleType = os:unmarshalInt32()
  self.num = os:unmarshalInt64()
end
return MoneyAwardBean
