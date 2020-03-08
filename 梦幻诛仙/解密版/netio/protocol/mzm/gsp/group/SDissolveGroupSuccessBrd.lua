local SDissolveGroupSuccessBrd = class("SDissolveGroupSuccessBrd")
SDissolveGroupSuccessBrd.TYPEID = 12605188
function SDissolveGroupSuccessBrd:ctor(groupid, group_name)
  self.id = 12605188
  self.groupid = groupid or nil
  self.group_name = group_name or nil
end
function SDissolveGroupSuccessBrd:marshal(os)
  os:marshalInt64(self.groupid)
  os:marshalOctets(self.group_name)
end
function SDissolveGroupSuccessBrd:unmarshal(os)
  self.groupid = os:unmarshalInt64()
  self.group_name = os:unmarshalOctets()
end
function SDissolveGroupSuccessBrd:sizepolicy(size)
  return size <= 65535
end
return SDissolveGroupSuccessBrd
