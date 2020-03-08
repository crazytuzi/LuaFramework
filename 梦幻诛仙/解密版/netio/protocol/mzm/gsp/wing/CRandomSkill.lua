local CRandomSkill = class("CRandomSkill")
CRandomSkill.TYPEID = 12596482
function CRandomSkill:ctor(index, isUseYuanbao, clientYuanbaoNum, clientNeedYuanbaoNum)
  self.id = 12596482
  self.index = index or nil
  self.isUseYuanbao = isUseYuanbao or nil
  self.clientYuanbaoNum = clientYuanbaoNum or nil
  self.clientNeedYuanbaoNum = clientNeedYuanbaoNum or nil
end
function CRandomSkill:marshal(os)
  os:marshalInt32(self.index)
  os:marshalInt32(self.isUseYuanbao)
  os:marshalInt64(self.clientYuanbaoNum)
  os:marshalInt32(self.clientNeedYuanbaoNum)
end
function CRandomSkill:unmarshal(os)
  self.index = os:unmarshalInt32()
  self.isUseYuanbao = os:unmarshalInt32()
  self.clientYuanbaoNum = os:unmarshalInt64()
  self.clientNeedYuanbaoNum = os:unmarshalInt32()
end
function CRandomSkill:sizepolicy(size)
  return size <= 65535
end
return CRandomSkill
