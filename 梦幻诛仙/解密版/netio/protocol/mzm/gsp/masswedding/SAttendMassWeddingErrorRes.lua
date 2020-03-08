local SAttendMassWeddingErrorRes = class("SAttendMassWeddingErrorRes")
SAttendMassWeddingErrorRes.TYPEID = 12604945
SAttendMassWeddingErrorRes.ACTIVITY_NOT_OPEN = 1
SAttendMassWeddingErrorRes.ACTIVITY_CLOSED = 2
function SAttendMassWeddingErrorRes:ctor(result, args)
  self.id = 12604945
  self.result = result or nil
  self.args = args or {}
end
function SAttendMassWeddingErrorRes:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SAttendMassWeddingErrorRes:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SAttendMassWeddingErrorRes:sizepolicy(size)
  return size <= 65535
end
return SAttendMassWeddingErrorRes
