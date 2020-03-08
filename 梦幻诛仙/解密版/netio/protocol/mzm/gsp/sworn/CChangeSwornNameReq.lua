local CChangeSwornNameReq = class("CChangeSwornNameReq")
CChangeSwornNameReq.TYPEID = 12597794
function CChangeSwornNameReq:ctor(name1, name2)
  self.id = 12597794
  self.name1 = name1 or nil
  self.name2 = name2 or nil
end
function CChangeSwornNameReq:marshal(os)
  os:marshalString(self.name1)
  os:marshalString(self.name2)
end
function CChangeSwornNameReq:unmarshal(os)
  self.name1 = os:unmarshalString()
  self.name2 = os:unmarshalString()
end
function CChangeSwornNameReq:sizepolicy(size)
  return size <= 65535
end
return CChangeSwornNameReq
