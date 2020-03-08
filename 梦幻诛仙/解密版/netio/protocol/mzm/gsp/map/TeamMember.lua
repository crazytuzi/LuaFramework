local OctetsStream = require("netio.OctetsStream")
local TeamMember = class("TeamMember")
TeamMember.KEY_PET = 1
TeamMember.KEY_CHILDREN = 2
function TeamMember:ctor(roleId, modelInfo, models)
  self.roleId = roleId or nil
  self.modelInfo = modelInfo or nil
  self.models = models or {}
end
function TeamMember:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalOctets(self.modelInfo)
  local _size_ = 0
  for _, _ in pairs(self.models) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.models) do
    os:marshalInt32(k)
    os:marshalOctets(v)
  end
end
function TeamMember:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.modelInfo = os:unmarshalOctets()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalOctets()
    self.models[k] = v
  end
end
return TeamMember
