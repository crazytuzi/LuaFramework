local CResetMainSkill = class("CResetMainSkill")
CResetMainSkill.TYPEID = 12596513
function CResetMainSkill:ctor(index, skillIndex, isUseYuanbao, clientYuanbaoNum, clientNeedYuanbaoNum)
  self.id = 12596513
  self.index = index or nil
  self.skillIndex = skillIndex or nil
  self.isUseYuanbao = isUseYuanbao or nil
  self.clientYuanbaoNum = clientYuanbaoNum or nil
  self.clientNeedYuanbaoNum = clientNeedYuanbaoNum or nil
end
function CResetMainSkill:marshal(os)
  os:marshalInt32(self.index)
  os:marshalInt32(self.skillIndex)
  os:marshalInt32(self.isUseYuanbao)
  os:marshalInt64(self.clientYuanbaoNum)
  os:marshalInt32(self.clientNeedYuanbaoNum)
end
function CResetMainSkill:unmarshal(os)
  self.index = os:unmarshalInt32()
  self.skillIndex = os:unmarshalInt32()
  self.isUseYuanbao = os:unmarshalInt32()
  self.clientYuanbaoNum = os:unmarshalInt64()
  self.clientNeedYuanbaoNum = os:unmarshalInt32()
end
function CResetMainSkill:sizepolicy(size)
  return size <= 65535
end
return CResetMainSkill
