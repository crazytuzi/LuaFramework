local CRenameReq = class("CRenameReq")
CRenameReq.TYPEID = 12589850
function CRenameReq:ctor(newName)
  self.id = 12589850
  self.newName = newName or nil
end
function CRenameReq:marshal(os)
  os:marshalString(self.newName)
end
function CRenameReq:unmarshal(os)
  self.newName = os:unmarshalString()
end
function CRenameReq:sizepolicy(size)
  return size <= 65535
end
return CRenameReq
