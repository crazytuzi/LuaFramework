local CCatRename = class("CCatRename")
CCatRename.TYPEID = 12605706
function CCatRename:ctor(cat_name)
  self.id = 12605706
  self.cat_name = cat_name or nil
end
function CCatRename:marshal(os)
  os:marshalOctets(self.cat_name)
end
function CCatRename:unmarshal(os)
  self.cat_name = os:unmarshalOctets()
end
function CCatRename:sizepolicy(size)
  return size <= 65535
end
return CCatRename
