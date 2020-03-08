local CChangeChannelInfo = class("CChangeChannelInfo")
CChangeChannelInfo.TYPEID = 12585223
function CChangeChannelInfo:ctor(chatCfgInfo)
  self.id = 12585223
  self.chatCfgInfo = chatCfgInfo or {}
end
function CChangeChannelInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.chatCfgInfo) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.chatCfgInfo) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function CChangeChannelInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.chatCfgInfo[k] = v
  end
end
function CChangeChannelInfo:sizepolicy(size)
  return size <= 65535
end
return CChangeChannelInfo
