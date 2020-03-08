local CCreateHomelandReq = class("CCreateHomelandReq")
CCreateHomelandReq.TYPEID = 12605447
function CCreateHomelandReq:ctor(createType)
  self.id = 12605447
  self.createType = createType or nil
end
function CCreateHomelandReq:marshal(os)
  os:marshalInt32(self.createType)
end
function CCreateHomelandReq:unmarshal(os)
  self.createType = os:unmarshalInt32()
end
function CCreateHomelandReq:sizepolicy(size)
  return size <= 65535
end
return CCreateHomelandReq
