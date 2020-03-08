local SParadeAttackErrorRes = class("SParadeAttackErrorRes")
SParadeAttackErrorRes.TYPEID = 12599851
SParadeAttackErrorRes.MARRIAGE_PARADE_BRIDE_IN_FIGHT = 1
SParadeAttackErrorRes.MARRIAGE_PARADE_BRIDE_ALREADY_CHALLENGED = 2
SParadeAttackErrorRes.MARRIAGE_PARADE_GROOM_IN_FIGHT = 21
SParadeAttackErrorRes.MARRIAGE_PARADE_GROOM_ALREADY_CHALLENGED = 22
SParadeAttackErrorRes.MARRIAGE_ROB_PARADE_TO_MAX = 100
SParadeAttackErrorRes.MARRIAGE_ATTACK_PROTECT_TO_MAX = 101
SParadeAttackErrorRes.MARRIAGE_PARADE_END = 102
SParadeAttackErrorRes.MARRIAGE_ROB_PARADE_TO_MAX_SELF = 103
SParadeAttackErrorRes.MARRIAGE_ATTACK_PROTECT_TO_MAX_SELF = 104
function SParadeAttackErrorRes:ctor(result, args)
  self.id = 12599851
  self.result = result or nil
  self.args = args or {}
end
function SParadeAttackErrorRes:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SParadeAttackErrorRes:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SParadeAttackErrorRes:sizepolicy(size)
  return size <= 65535
end
return SParadeAttackErrorRes
