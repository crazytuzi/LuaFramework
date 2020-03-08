local SResetDeclarationBro = class("SResetDeclarationBro")
SResetDeclarationBro.TYPEID = 12617490
function SResetDeclarationBro:ctor(declaration)
  self.id = 12617490
  self.declaration = declaration or nil
end
function SResetDeclarationBro:marshal(os)
  os:marshalOctets(self.declaration)
end
function SResetDeclarationBro:unmarshal(os)
  self.declaration = os:unmarshalOctets()
end
function SResetDeclarationBro:sizepolicy(size)
  return size <= 65535
end
return SResetDeclarationBro
