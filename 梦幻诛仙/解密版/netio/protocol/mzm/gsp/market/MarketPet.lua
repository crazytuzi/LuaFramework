local OctetsStream = require("netio.OctetsStream")
local MarketPet = class("MarketPet")
function MarketPet:ctor(marketId, petCfgId, petLevel, price, state, concernRoleNum, publicEndTime)
  self.marketId = marketId or nil
  self.petCfgId = petCfgId or nil
  self.petLevel = petLevel or nil
  self.price = price or nil
  self.state = state or nil
  self.concernRoleNum = concernRoleNum or nil
  self.publicEndTime = publicEndTime or nil
end
function MarketPet:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.petCfgId)
  os:marshalInt32(self.petLevel)
  os:marshalInt32(self.price)
  os:marshalInt32(self.state)
  os:marshalInt32(self.concernRoleNum)
  os:marshalInt64(self.publicEndTime)
end
function MarketPet:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.petCfgId = os:unmarshalInt32()
  self.petLevel = os:unmarshalInt32()
  self.price = os:unmarshalInt32()
  self.state = os:unmarshalInt32()
  self.concernRoleNum = os:unmarshalInt32()
  self.publicEndTime = os:unmarshalInt64()
end
return MarketPet
