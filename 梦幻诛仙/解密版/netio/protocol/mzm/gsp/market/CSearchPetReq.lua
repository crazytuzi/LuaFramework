local PetCondition = require("netio.protocol.mzm.gsp.market.PetCondition")
local CSearchPetReq = class("CSearchPetReq")
CSearchPetReq.TYPEID = 12601413
function CSearchPetReq:ctor(condition, pubOrsell, pricesort, pageIndex)
  self.id = 12601413
  self.condition = condition or PetCondition.new()
  self.pubOrsell = pubOrsell or nil
  self.pricesort = pricesort or nil
  self.pageIndex = pageIndex or nil
end
function CSearchPetReq:marshal(os)
  self.condition:marshal(os)
  os:marshalInt32(self.pubOrsell)
  os:marshalInt32(self.pricesort)
  os:marshalInt32(self.pageIndex)
end
function CSearchPetReq:unmarshal(os)
  self.condition = PetCondition.new()
  self.condition:unmarshal(os)
  self.pubOrsell = os:unmarshalInt32()
  self.pricesort = os:unmarshalInt32()
  self.pageIndex = os:unmarshalInt32()
end
function CSearchPetReq:sizepolicy(size)
  return size <= 65535
end
return CSearchPetReq
