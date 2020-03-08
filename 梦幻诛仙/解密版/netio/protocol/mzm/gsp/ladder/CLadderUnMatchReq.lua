local CLadderUnMatchReq = class("CLadderUnMatchReq")
CLadderUnMatchReq.TYPEID = 12607233
function CLadderUnMatchReq:ctor()
  self.id = 12607233
end
function CLadderUnMatchReq:marshal(os)
end
function CLadderUnMatchReq:unmarshal(os)
end
function CLadderUnMatchReq:sizepolicy(size)
  return size <= 65535
end
return CLadderUnMatchReq
