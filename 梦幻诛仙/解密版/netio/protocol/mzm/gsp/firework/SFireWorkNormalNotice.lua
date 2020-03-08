local SFireWorkNormalNotice = class("SFireWorkNormalNotice")
SFireWorkNormalNotice.TYPEID = 12625162
SFireWorkNormalNotice.FIRE_WORK_START__FLY = 1
function SFireWorkNormalNotice:ctor(result, args)
  self.id = 12625162
  self.result = result or nil
  self.args = args or {}
end
function SFireWorkNormalNotice:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SFireWorkNormalNotice:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SFireWorkNormalNotice:sizepolicy(size)
  return size <= 65535
end
return SFireWorkNormalNotice
