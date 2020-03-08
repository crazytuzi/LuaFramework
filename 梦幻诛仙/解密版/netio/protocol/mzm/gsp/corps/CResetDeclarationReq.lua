local CResetDeclarationReq = class("CResetDeclarationReq")
CResetDeclarationReq.TYPEID = 12617497
function CResetDeclarationReq:ctor(declaration)
  self.id = 12617497
  self.declaration = declaration or nil
end
function CResetDeclarationReq:marshal(os)
  os:marshalOctets(self.declaration)
end
function CResetDeclarationReq:unmarshal(os)
  self.declaration = os:unmarshalOctets()
end
function CResetDeclarationReq:sizepolicy(size)
  return size <= 65535
end
return CResetDeclarationReq
