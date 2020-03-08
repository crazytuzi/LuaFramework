local PetEquipCondition = require("netio.protocol.mzm.gsp.market.PetEquipCondition")
local PageItemInfo = require("netio.protocol.mzm.gsp.market.PageItemInfo")
local SSearchPetEquipRes = class("SSearchPetEquipRes")
SSearchPetEquipRes.TYPEID = 12601414
function SSearchPetEquipRes:ctor(condition, pubOrsell, pricesort, pageResult)
  self.id = 12601414
  self.condition = condition or PetEquipCondition.new()
  self.pubOrsell = pubOrsell or nil
  self.pricesort = pricesort or nil
  self.pageResult = pageResult or PageItemInfo.new()
end
function SSearchPetEquipRes:marshal(os)
  self.condition:marshal(os)
  os:marshalInt32(self.pubOrsell)
  os:marshalInt32(self.pricesort)
  self.pageResult:marshal(os)
end
function SSearchPetEquipRes:unmarshal(os)
  self.condition = PetEquipCondition.new()
  self.condition:unmarshal(os)
  self.pubOrsell = os:unmarshalInt32()
  self.pricesort = os:unmarshalInt32()
  self.pageResult = PageItemInfo.new()
  self.pageResult:unmarshal(os)
end
function SSearchPetEquipRes:sizepolicy(size)
  return size <= 65535
end
return SSearchPetEquipRes
