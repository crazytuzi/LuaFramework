local CConfirmApplyJoinGangReq = class("CConfirmApplyJoinGangReq")
CConfirmApplyJoinGangReq.TYPEID = 12589889
function CConfirmApplyJoinGangReq:ctor(roleId)
  self.id = 12589889
  self.roleId = roleId or nil
end
function CConfirmApplyJoinGangReq:marshal(os)
  os:marshalInt64(self.roleId)
end
function CConfirmApplyJoinGangReq:unmarshal(os)
  self.roleId = os:unmarshalInt64()
end
function CConfirmApplyJoinGangReq:sizepolicy(size)
  return size <= 65535
end
return CConfirmApplyJoinGangReq
