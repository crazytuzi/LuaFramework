local SGetNewTitleOrAppellation = class("SGetNewTitleOrAppellation")
SGetNewTitleOrAppellation.TYPEID = 12593923
function SGetNewTitleOrAppellation:ctor(changeId, changeType, appArgs, timeout)
  self.id = 12593923
  self.changeId = changeId or nil
  self.changeType = changeType or nil
  self.appArgs = appArgs or {}
  self.timeout = timeout or nil
end
function SGetNewTitleOrAppellation:marshal(os)
  os:marshalInt32(self.changeId)
  os:marshalInt32(self.changeType)
  os:marshalCompactUInt32(table.getn(self.appArgs))
  for _, v in ipairs(self.appArgs) do
    os:marshalString(v)
  end
  os:marshalInt64(self.timeout)
end
function SGetNewTitleOrAppellation:unmarshal(os)
  self.changeId = os:unmarshalInt32()
  self.changeType = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.appArgs, v)
  end
  self.timeout = os:unmarshalInt64()
end
function SGetNewTitleOrAppellation:sizepolicy(size)
  return size <= 65535
end
return SGetNewTitleOrAppellation
