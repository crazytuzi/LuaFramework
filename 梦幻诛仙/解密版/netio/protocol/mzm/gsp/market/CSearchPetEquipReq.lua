local PetEquipCondition = require("netio.protocol.mzm.gsp.market.PetEquipCondition")
local CSearchPetEquipReq = class("CSearchPetEquipReq")
CSearchPetEquipReq.TYPEID = 12601407
function CSearchPetEquipReq:ctor(condition, pubOrsell, pricesort, pageIndex)
  self.id = 12601407
  self.condition = condition or PetEquipCondition.new()
  self.pubOrsell = pubOrsell or nil
  self.pricesort = pricesort or nil
  self.pageIndex = pageIndex or nil
end
function CSearchPetEquipReq:marshal(os)
  self.condition:marshal(os)
  os:marshalInt32(self.pubOrsell)
  os:marshalInt32(self.pricesort)
  os:marshalInt32(self.pageIndex)
end
function CSearchPetEquipReq:unmarshal(os)
  self.condition = PetEquipCondition.new()
  self.condition:unmarshal(os)
  self.pubOrsell = os:unmarshalInt32()
  self.pricesort = os:unmarshalInt32()
  self.pageIndex = os:unmarshalInt32()
end
function CSearchPetEquipReq:sizepolicy(size)
  return size <= 65535
end
return CSearchPetEquipReq
