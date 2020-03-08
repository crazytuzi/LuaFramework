local OctetsStream = require("netio.OctetsStream")
local GangHelp = class("GangHelp")
GangHelp.TYPE_ITEM = 0
GangHelp.ITEM_ID = 0
GangHelp.ACTIVITY_ID = 1
GangHelp.ITEMNUM_ID = 2
GangHelp.CAOWEI = 3
GangHelp.HELP_KEY = 4
function GangHelp:ctor(uId, roleId, helpType, intMap)
  self.uId = uId or nil
  self.roleId = roleId or nil
  self.helpType = helpType or nil
  self.intMap = intMap or {}
end
function GangHelp:marshal(os)
  os:marshalInt64(self.uId)
  os:marshalInt64(self.roleId)
  os:marshalInt32(self.helpType)
  local _size_ = 0
  for _, _ in pairs(self.intMap) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.intMap) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function GangHelp:unmarshal(os)
  self.uId = os:unmarshalInt64()
  self.roleId = os:unmarshalInt64()
  self.helpType = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.intMap[k] = v
  end
end
return GangHelp
