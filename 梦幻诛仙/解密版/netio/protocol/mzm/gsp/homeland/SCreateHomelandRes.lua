local SCreateHomelandRes = class("SCreateHomelandRes")
SCreateHomelandRes.TYPEID = 12605473
function SCreateHomelandRes:ctor(homeLevel)
  self.id = 12605473
  self.homeLevel = homeLevel or nil
end
function SCreateHomelandRes:marshal(os)
  os:marshalInt32(self.homeLevel)
end
function SCreateHomelandRes:unmarshal(os)
  self.homeLevel = os:unmarshalInt32()
end
function SCreateHomelandRes:sizepolicy(size)
  return size <= 65535
end
return SCreateHomelandRes
