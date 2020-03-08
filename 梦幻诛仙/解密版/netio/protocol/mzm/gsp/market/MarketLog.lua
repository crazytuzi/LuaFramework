local OctetsStream = require("netio.OctetsStream")
local MarketLog = class("MarketLog")
function MarketLog:ctor(roleName, price, itemIdOrPetCfgId, num, time)
  self.roleName = roleName or nil
  self.price = price or nil
  self.itemIdOrPetCfgId = itemIdOrPetCfgId or nil
  self.num = num or nil
  self.time = time or nil
end
function MarketLog:marshal(os)
  os:marshalString(self.roleName)
  os:marshalInt32(self.price)
  os:marshalInt32(self.itemIdOrPetCfgId)
  os:marshalInt32(self.num)
  os:marshalInt64(self.time)
end
function MarketLog:unmarshal(os)
  self.roleName = os:unmarshalString()
  self.price = os:unmarshalInt32()
  self.itemIdOrPetCfgId = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
  self.time = os:unmarshalInt64()
end
return MarketLog
