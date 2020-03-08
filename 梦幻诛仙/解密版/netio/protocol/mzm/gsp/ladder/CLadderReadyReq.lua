local CLadderReadyReq = class("CLadderReadyReq")
CLadderReadyReq.TYPEID = 12607240
function CLadderReadyReq:ctor()
  self.id = 12607240
end
function CLadderReadyReq:marshal(os)
end
function CLadderReadyReq:unmarshal(os)
end
function CLadderReadyReq:sizepolicy(size)
  return size <= 65535
end
return CLadderReadyReq
