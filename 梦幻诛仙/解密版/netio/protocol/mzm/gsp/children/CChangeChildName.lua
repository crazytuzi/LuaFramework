local CChangeChildName = class("CChangeChildName")
CChangeChildName.TYPEID = 12609333
function CChangeChildName:ctor(child_id, child_new_name)
  self.id = 12609333
  self.child_id = child_id or nil
  self.child_new_name = child_new_name or nil
end
function CChangeChildName:marshal(os)
  os:marshalInt64(self.child_id)
  os:marshalOctets(self.child_new_name)
end
function CChangeChildName:unmarshal(os)
  self.child_id = os:unmarshalInt64()
  self.child_new_name = os:unmarshalOctets()
end
function CChangeChildName:sizepolicy(size)
  return size <= 65535
end
return CChangeChildName
