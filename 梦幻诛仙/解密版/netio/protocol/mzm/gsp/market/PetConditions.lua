local OctetsStream = require("netio.OctetsStream")
local PetConditions = class("PetConditions")
function PetConditions:ctor(petCons, conditionState)
  self.petCons = petCons or {}
  self.conditionState = conditionState or {}
end
function PetConditions:marshal(os)
  os:marshalCompactUInt32(table.getn(self.petCons))
  for _, v in ipairs(self.petCons) do
    v:marshal(os)
  end
  os:marshalCompactUInt32(table.getn(self.conditionState))
  for _, v in ipairs(self.conditionState) do
    os:marshalInt32(v)
  end
end
function PetConditions:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.market.PetCondition")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.petCons, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.conditionState, v)
  end
end
return PetConditions
