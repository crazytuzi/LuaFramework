local CLeavefubenReq = class("CLeavefubenReq")
CLeavefubenReq.TYPEID = 12598276
function CLeavefubenReq:ctor()
  self.id = 12598276
end
function CLeavefubenReq:marshal(os)
end
function CLeavefubenReq:unmarshal(os)
end
function CLeavefubenReq:sizepolicy(size)
  return size <= 65535
end
return CLeavefubenReq
