local CCreateGangReq = class("CCreateGangReq")
CCreateGangReq.TYPEID = 12589867
function CCreateGangReq:ctor(name, purpose)
  self.id = 12589867
  self.name = name or nil
  self.purpose = purpose or nil
end
function CCreateGangReq:marshal(os)
  os:marshalString(self.name)
  os:marshalString(self.purpose)
end
function CCreateGangReq:unmarshal(os)
  self.name = os:unmarshalString()
  self.purpose = os:unmarshalString()
end
function CCreateGangReq:sizepolicy(size)
  return size <= 65535
end
return CCreateGangReq
