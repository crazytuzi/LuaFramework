local SVigorWorkRes = class("SVigorWorkRes")
SVigorWorkRes.TYPEID = 12586008
function SVigorWorkRes:ctor(addSilver)
  self.id = 12586008
  self.addSilver = addSilver or nil
end
function SVigorWorkRes:marshal(os)
  os:marshalInt32(self.addSilver)
end
function SVigorWorkRes:unmarshal(os)
  self.addSilver = os:unmarshalInt32()
end
function SVigorWorkRes:sizepolicy(size)
  return size <= 65535
end
return SVigorWorkRes
