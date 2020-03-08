local CGetClassMateApprenticeInfo = class("CGetClassMateApprenticeInfo")
CGetClassMateApprenticeInfo.TYPEID = 12601623
function CGetClassMateApprenticeInfo:ctor(startPos)
  self.id = 12601623
  self.startPos = startPos or nil
end
function CGetClassMateApprenticeInfo:marshal(os)
  os:marshalInt32(self.startPos)
end
function CGetClassMateApprenticeInfo:unmarshal(os)
  self.startPos = os:unmarshalInt32()
end
function CGetClassMateApprenticeInfo:sizepolicy(size)
  return size <= 65535
end
return CGetClassMateApprenticeInfo
