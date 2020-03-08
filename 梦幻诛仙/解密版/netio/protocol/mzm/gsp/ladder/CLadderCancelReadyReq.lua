local CLadderCancelReadyReq = class("CLadderCancelReadyReq")
CLadderCancelReadyReq.TYPEID = 12607235
function CLadderCancelReadyReq:ctor()
  self.id = 12607235
end
function CLadderCancelReadyReq:marshal(os)
end
function CLadderCancelReadyReq:unmarshal(os)
end
function CLadderCancelReadyReq:sizepolicy(size)
  return size <= 65535
end
return CLadderCancelReadyReq
