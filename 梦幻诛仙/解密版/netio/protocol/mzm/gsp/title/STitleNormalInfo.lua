local STitleNormalInfo = class("STitleNormalInfo")
STitleNormalInfo.TYPEID = 12593925
STitleNormalInfo.APPELLATION = 0
STitleNormalInfo.TITLE = 1
STitleNormalInfo.PROPERTY_OFF = 0
STitleNormalInfo.PROPERTY_ON = 1
STitleNormalInfo.PROPERTY_ADD = 0
STitleNormalInfo.PROPERTY_DEL = 1
function STitleNormalInfo:ctor(result, args)
  self.id = 12593925
  self.result = result or nil
  self.args = args or {}
end
function STitleNormalInfo:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function STitleNormalInfo:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function STitleNormalInfo:sizepolicy(size)
  return size <= 65535
end
return STitleNormalInfo
