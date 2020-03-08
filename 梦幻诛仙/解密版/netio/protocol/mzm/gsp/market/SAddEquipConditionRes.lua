local EquipCondition = require("netio.protocol.mzm.gsp.market.EquipCondition")
local SAddEquipConditionRes = class("SAddEquipConditionRes")
SAddEquipConditionRes.TYPEID = 12601418
function SAddEquipConditionRes:ctor(index, condition)
  self.id = 12601418
  self.index = index or nil
  self.condition = condition or EquipCondition.new()
end
function SAddEquipConditionRes:marshal(os)
  os:marshalInt32(self.index)
  self.condition:marshal(os)
end
function SAddEquipConditionRes:unmarshal(os)
  self.index = os:unmarshalInt32()
  self.condition = EquipCondition.new()
  self.condition:unmarshal(os)
end
function SAddEquipConditionRes:sizepolicy(size)
  return size <= 65535
end
return SAddEquipConditionRes
