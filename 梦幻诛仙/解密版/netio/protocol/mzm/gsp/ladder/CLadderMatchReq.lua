local CLadderMatchReq = class("CLadderMatchReq")
CLadderMatchReq.TYPEID = 12607239
function CLadderMatchReq:ctor()
  self.id = 12607239
end
function CLadderMatchReq:marshal(os)
end
function CLadderMatchReq:unmarshal(os)
end
function CLadderMatchReq:sizepolicy(size)
  return size <= 65535
end
return CLadderMatchReq
