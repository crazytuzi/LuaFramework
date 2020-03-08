local CSTTReq = class("CSTTReq")
CSTTReq.TYPEID = 12602637
function CSTTReq:ctor(file_id)
  self.id = 12602637
  self.file_id = file_id or nil
end
function CSTTReq:marshal(os)
  os:marshalOctets(self.file_id)
end
function CSTTReq:unmarshal(os)
  self.file_id = os:unmarshalOctets()
end
function CSTTReq:sizepolicy(size)
  return size <= 65535
end
return CSTTReq
