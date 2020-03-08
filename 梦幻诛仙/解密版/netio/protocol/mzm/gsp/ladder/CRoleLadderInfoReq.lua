local CRoleLadderInfoReq = class("CRoleLadderInfoReq")
CRoleLadderInfoReq.TYPEID = 12607263
function CRoleLadderInfoReq:ctor()
  self.id = 12607263
end
function CRoleLadderInfoReq:marshal(os)
end
function CRoleLadderInfoReq:unmarshal(os)
end
function CRoleLadderInfoReq:sizepolicy(size)
  return size <= 65535
end
return CRoleLadderInfoReq
