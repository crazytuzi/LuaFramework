local CAgreeOrRefuseReq = class("CAgreeOrRefuseReq")
CAgreeOrRefuseReq.TYPEID = 12600839
function CAgreeOrRefuseReq:ctor(roleid1, result, invitetime)
  self.id = 12600839
  self.roleid1 = roleid1 or nil
  self.result = result or nil
  self.invitetime = invitetime or nil
end
function CAgreeOrRefuseReq:marshal(os)
  os:marshalInt64(self.roleid1)
  os:marshalInt32(self.result)
  os:marshalInt64(self.invitetime)
end
function CAgreeOrRefuseReq:unmarshal(os)
  self.roleid1 = os:unmarshalInt64()
  self.result = os:unmarshalInt32()
  self.invitetime = os:unmarshalInt64()
end
function CAgreeOrRefuseReq:sizepolicy(size)
  return size <= 65535
end
return CAgreeOrRefuseReq
