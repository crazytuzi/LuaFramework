local SChatNormalResult = class("SChatNormalResult")
SChatNormalResult.TYPEID = 12585239
SChatNormalResult.CUT_VIGOR_SUC = 1
SChatNormalResult.CHECK_PACKETINFO_ERROR__NO_ITEM = 10
SChatNormalResult.CHECK_PACKETINFO_ERROR__NO_PET = 11
SChatNormalResult.CHECK_PACKETINFO_ERROR__NO_MOUNTS = 12
function SChatNormalResult:ctor(result, args)
  self.id = 12585239
  self.result = result or nil
  self.args = args or {}
end
function SChatNormalResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SChatNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SChatNormalResult:sizepolicy(size)
  return size <= 65535
end
return SChatNormalResult
