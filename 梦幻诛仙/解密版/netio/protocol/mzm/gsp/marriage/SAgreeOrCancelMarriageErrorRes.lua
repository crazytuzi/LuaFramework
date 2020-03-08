local SAgreeOrCancelMarriageErrorRes = class("SAgreeOrCancelMarriageErrorRes")
SAgreeOrCancelMarriageErrorRes.TYPEID = 12599837
SAgreeOrCancelMarriageErrorRes.MONEY_NOT_ENOUGH = 1
SAgreeOrCancelMarriageErrorRes.ITEM_NOT_ENOUGH = 2
SAgreeOrCancelMarriageErrorRes.OTHER_IN_CEREMONY = 3
function SAgreeOrCancelMarriageErrorRes:ctor(error, args)
  self.id = 12599837
  self.error = error or nil
  self.args = args or {}
end
function SAgreeOrCancelMarriageErrorRes:marshal(os)
  os:marshalInt32(self.error)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SAgreeOrCancelMarriageErrorRes:unmarshal(os)
  self.error = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SAgreeOrCancelMarriageErrorRes:sizepolicy(size)
  return size <= 65535
end
return SAgreeOrCancelMarriageErrorRes
