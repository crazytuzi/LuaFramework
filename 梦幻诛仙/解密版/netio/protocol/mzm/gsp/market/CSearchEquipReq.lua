local EquipCondition = require("netio.protocol.mzm.gsp.market.EquipCondition")
local CSearchEquipReq = class("CSearchEquipReq")
CSearchEquipReq.TYPEID = 12601410
function CSearchEquipReq:ctor(condition, pubOrsell, pricesort, pageIndex)
  self.id = 12601410
  self.condition = condition or EquipCondition.new()
  self.pubOrsell = pubOrsell or nil
  self.pricesort = pricesort or nil
  self.pageIndex = pageIndex or nil
end
function CSearchEquipReq:marshal(os)
  self.condition:marshal(os)
  os:marshalInt32(self.pubOrsell)
  os:marshalInt32(self.pricesort)
  os:marshalInt32(self.pageIndex)
end
function CSearchEquipReq:unmarshal(os)
  self.condition = EquipCondition.new()
  self.condition:unmarshal(os)
  self.pubOrsell = os:unmarshalInt32()
  self.pricesort = os:unmarshalInt32()
  self.pageIndex = os:unmarshalInt32()
end
function CSearchEquipReq:sizepolicy(size)
  return size <= 65535
end
return CSearchEquipReq
