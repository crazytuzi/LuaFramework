local EquipCondition = require("netio.protocol.mzm.gsp.market.EquipCondition")
local PageItemInfo = require("netio.protocol.mzm.gsp.market.PageItemInfo")
local SSearchEquipRes = class("SSearchEquipRes")
SSearchEquipRes.TYPEID = 12601411
function SSearchEquipRes:ctor(condition, pubOrsell, pricesort, pageResult)
  self.id = 12601411
  self.condition = condition or EquipCondition.new()
  self.pubOrsell = pubOrsell or nil
  self.pricesort = pricesort or nil
  self.pageResult = pageResult or PageItemInfo.new()
end
function SSearchEquipRes:marshal(os)
  self.condition:marshal(os)
  os:marshalInt32(self.pubOrsell)
  os:marshalInt32(self.pricesort)
  self.pageResult:marshal(os)
end
function SSearchEquipRes:unmarshal(os)
  self.condition = EquipCondition.new()
  self.condition:unmarshal(os)
  self.pubOrsell = os:unmarshalInt32()
  self.pricesort = os:unmarshalInt32()
  self.pageResult = PageItemInfo.new()
  self.pageResult:unmarshal(os)
end
function SSearchEquipRes:sizepolicy(size)
  return size <= 65535
end
return SSearchEquipRes
