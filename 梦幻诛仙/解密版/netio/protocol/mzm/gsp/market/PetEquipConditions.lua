local OctetsStream = require("netio.OctetsStream")
local PetEquipConditions = class("PetEquipConditions")
function PetEquipConditions:ctor(petEquipCons, conditionState)
  self.petEquipCons = petEquipCons or {}
  self.conditionState = conditionState or {}
end
function PetEquipConditions:marshal(os)
  os:marshalCompactUInt32(table.getn(self.petEquipCons))
  for _, v in ipairs(self.petEquipCons) do
    v:marshal(os)
  end
  os:marshalCompactUInt32(table.getn(self.conditionState))
  for _, v in ipairs(self.conditionState) do
    os:marshalInt32(v)
  end
end
function PetEquipConditions:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.market.PetEquipCondition")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.petEquipCons, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.conditionState, v)
  end
end
return PetEquipConditions
