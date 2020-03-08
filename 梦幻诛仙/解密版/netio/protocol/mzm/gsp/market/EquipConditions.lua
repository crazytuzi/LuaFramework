local OctetsStream = require("netio.OctetsStream")
local EquipConditions = class("EquipConditions")
function EquipConditions:ctor(equipCons, conditionState)
  self.equipCons = equipCons or {}
  self.conditionState = conditionState or {}
end
function EquipConditions:marshal(os)
  os:marshalCompactUInt32(table.getn(self.equipCons))
  for _, v in ipairs(self.equipCons) do
    v:marshal(os)
  end
  os:marshalCompactUInt32(table.getn(self.conditionState))
  for _, v in ipairs(self.conditionState) do
    os:marshalInt32(v)
  end
end
function EquipConditions:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.market.EquipCondition")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.equipCons, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.conditionState, v)
  end
end
return EquipConditions
