local SCatRenameSuccess = class("SCatRenameSuccess")
SCatRenameSuccess.TYPEID = 12605703
function SCatRenameSuccess:ctor(cat_name)
  self.id = 12605703
  self.cat_name = cat_name or nil
end
function SCatRenameSuccess:marshal(os)
  os:marshalOctets(self.cat_name)
end
function SCatRenameSuccess:unmarshal(os)
  self.cat_name = os:unmarshalOctets()
end
function SCatRenameSuccess:sizepolicy(size)
  return size <= 65535
end
return SCatRenameSuccess
