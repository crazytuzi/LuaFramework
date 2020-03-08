local CGetChuShiApprenticeInfo = class("CGetChuShiApprenticeInfo")
CGetChuShiApprenticeInfo.TYPEID = 12601619
function CGetChuShiApprenticeInfo:ctor(startPos)
  self.id = 12601619
  self.startPos = startPos or nil
end
function CGetChuShiApprenticeInfo:marshal(os)
  os:marshalInt32(self.startPos)
end
function CGetChuShiApprenticeInfo:unmarshal(os)
  self.startPos = os:unmarshalInt32()
end
function CGetChuShiApprenticeInfo:sizepolicy(size)
  return size <= 65535
end
return CGetChuShiApprenticeInfo
