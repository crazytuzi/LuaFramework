local CCreateGroupReq = class("CCreateGroupReq")
CCreateGroupReq.TYPEID = 12605192
function CCreateGroupReq:ctor(group_type, group_name)
  self.id = 12605192
  self.group_type = group_type or nil
  self.group_name = group_name or nil
end
function CCreateGroupReq:marshal(os)
  os:marshalInt32(self.group_type)
  os:marshalOctets(self.group_name)
end
function CCreateGroupReq:unmarshal(os)
  self.group_type = os:unmarshalInt32()
  self.group_name = os:unmarshalOctets()
end
function CCreateGroupReq:sizepolicy(size)
  return size <= 65535
end
return CCreateGroupReq
