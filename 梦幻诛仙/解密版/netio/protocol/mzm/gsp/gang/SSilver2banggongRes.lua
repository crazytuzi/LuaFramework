local SSilver2banggongRes = class("SSilver2banggongRes")
SSilver2banggongRes.TYPEID = 12589911
function SSilver2banggongRes:ctor(level, silver2banggongHistory)
  self.id = 12589911
  self.level = level or nil
  self.silver2banggongHistory = silver2banggongHistory or nil
end
function SSilver2banggongRes:marshal(os)
  os:marshalInt32(self.level)
  os:marshalInt32(self.silver2banggongHistory)
end
function SSilver2banggongRes:unmarshal(os)
  self.level = os:unmarshalInt32()
  self.silver2banggongHistory = os:unmarshalInt32()
end
function SSilver2banggongRes:sizepolicy(size)
  return size <= 65535
end
return SSilver2banggongRes
