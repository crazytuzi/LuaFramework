local CConfirmApplyJoinGangListReq = class("CConfirmApplyJoinGangListReq")
CConfirmApplyJoinGangListReq.TYPEID = 12589938
function CConfirmApplyJoinGangListReq:ctor()
  self.id = 12589938
end
function CConfirmApplyJoinGangListReq:marshal(os)
end
function CConfirmApplyJoinGangListReq:unmarshal(os)
end
function CConfirmApplyJoinGangListReq:sizepolicy(size)
  return size <= 65535
end
return CConfirmApplyJoinGangListReq
