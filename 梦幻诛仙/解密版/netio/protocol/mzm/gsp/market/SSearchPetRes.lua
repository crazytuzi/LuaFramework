local PetCondition = require("netio.protocol.mzm.gsp.market.PetCondition")
local PagePetInfo = require("netio.protocol.mzm.gsp.market.PagePetInfo")
local SSearchPetRes = class("SSearchPetRes")
SSearchPetRes.TYPEID = 12601416
function SSearchPetRes:ctor(condition, pubOrsell, pricesort, pageResult)
  self.id = 12601416
  self.condition = condition or PetCondition.new()
  self.pubOrsell = pubOrsell or nil
  self.pricesort = pricesort or nil
  self.pageResult = pageResult or PagePetInfo.new()
end
function SSearchPetRes:marshal(os)
  self.condition:marshal(os)
  os:marshalInt32(self.pubOrsell)
  os:marshalInt32(self.pricesort)
  self.pageResult:marshal(os)
end
function SSearchPetRes:unmarshal(os)
  self.condition = PetCondition.new()
  self.condition:unmarshal(os)
  self.pubOrsell = os:unmarshalInt32()
  self.pricesort = os:unmarshalInt32()
  self.pageResult = PagePetInfo.new()
  self.pageResult:unmarshal(os)
end
function SSearchPetRes:sizepolicy(size)
  return size <= 65535
end
return SSearchPetRes
