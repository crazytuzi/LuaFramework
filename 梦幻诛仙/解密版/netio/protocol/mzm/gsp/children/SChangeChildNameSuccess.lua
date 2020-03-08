local SChangeChildNameSuccess = class("SChangeChildNameSuccess")
SChangeChildNameSuccess.TYPEID = 12609332
function SChangeChildNameSuccess:ctor(child_id, child_new_name)
  self.id = 12609332
  self.child_id = child_id or nil
  self.child_new_name = child_new_name or nil
end
function SChangeChildNameSuccess:marshal(os)
  os:marshalInt64(self.child_id)
  os:marshalOctets(self.child_new_name)
end
function SChangeChildNameSuccess:unmarshal(os)
  self.child_id = os:unmarshalInt64()
  self.child_new_name = os:unmarshalOctets()
end
function SChangeChildNameSuccess:sizepolicy(size)
  return size <= 65535
end
return SChangeChildNameSuccess
