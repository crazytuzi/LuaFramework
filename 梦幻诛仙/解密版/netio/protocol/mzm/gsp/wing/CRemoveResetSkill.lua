local CRemoveResetSkill = class("CRemoveResetSkill")
CRemoveResetSkill.TYPEID = 12596516
function CRemoveResetSkill:ctor(index)
  self.id = 12596516
  self.index = index or nil
end
function CRemoveResetSkill:marshal(os)
  os:marshalInt32(self.index)
end
function CRemoveResetSkill:unmarshal(os)
  self.index = os:unmarshalInt32()
end
function CRemoveResetSkill:sizepolicy(size)
  return size <= 65535
end
return CRemoveResetSkill
