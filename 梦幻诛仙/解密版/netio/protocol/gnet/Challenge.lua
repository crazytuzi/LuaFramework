local ServerAttr = require("netio.protocol.gnet.ServerAttr")
local Challenge = class("Challenge")
Challenge.TYPEID = 101
function Challenge:ctor(nonce, version, serverattr, resource_versions)
  self.id = 101
  self.nonce = nonce or nil
  self.version = version or nil
  self.serverattr = serverattr or ServerAttr.new()
  self.resource_versions = resource_versions or {}
end
function Challenge:marshal(os)
  os:marshalOctets(self.nonce)
  os:marshalInt32(self.version)
  self.serverattr:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.resource_versions) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.resource_versions) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function Challenge:unmarshal(os)
  self.nonce = os:unmarshalOctets()
  self.version = os:unmarshalInt32()
  self.serverattr = ServerAttr.new()
  self.serverattr:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.resource_versions[k] = v
  end
end
function Challenge:sizepolicy(size)
  return size <= 65535
end
return Challenge
