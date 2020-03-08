local CQueryResetSkill = class("CQueryResetSkill")
CQueryResetSkill.TYPEID = 12596519
function CQueryResetSkill:ctor(index)
  self.id = 12596519
  self.index = index or nil
end
function CQueryResetSkill:marshal(os)
  os:marshalInt32(self.index)
end
function CQueryResetSkill:unmarshal(os)
  self.index = os:unmarshalInt32()
end
function CQueryResetSkill:sizepolicy(size)
  return size <= 65535
end
return CQueryResetSkill
