local SPetBanTradeRes = class("SPetBanTradeRes")
SPetBanTradeRes.TYPEID = 12601456
function SPetBanTradeRes:ctor(petCfgId, state)
  self.id = 12601456
  self.petCfgId = petCfgId or nil
  self.state = state or nil
end
function SPetBanTradeRes:marshal(os)
  os:marshalInt32(self.petCfgId)
  os:marshalInt32(self.state)
end
function SPetBanTradeRes:unmarshal(os)
  self.petCfgId = os:unmarshalInt32()
  self.state = os:unmarshalInt32()
end
function SPetBanTradeRes:sizepolicy(size)
  return size <= 65535
end
return SPetBanTradeRes
