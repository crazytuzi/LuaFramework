local CGetRoleInfoByNameReq = class("CGetRoleInfoByNameReq")
CGetRoleInfoByNameReq.TYPEID = 12586036
function CGetRoleInfoByNameReq:ctor(name)
  self.id = 12586036
  self.name = name or nil
end
function CGetRoleInfoByNameReq:marshal(os)
  os:marshalOctets(self.name)
end
function CGetRoleInfoByNameReq:unmarshal(os)
  self.name = os:unmarshalOctets()
end
function CGetRoleInfoByNameReq:sizepolicy(size)
  return size <= 65535
end
return CGetRoleInfoByNameReq
