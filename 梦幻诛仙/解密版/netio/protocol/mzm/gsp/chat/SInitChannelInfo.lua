local SInitChannelInfo = class("SInitChannelInfo")
SInitChannelInfo.TYPEID = 12585224
function SInitChannelInfo:ctor(chatCfgInfo)
  self.id = 12585224
  self.chatCfgInfo = chatCfgInfo or {}
end
function SInitChannelInfo:marshal(os)
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
function SInitChannelInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.chatCfgInfo[k] = v
  end
end
function SInitChannelInfo:sizepolicy(size)
  return size <= 65535
end
return SInitChannelInfo
