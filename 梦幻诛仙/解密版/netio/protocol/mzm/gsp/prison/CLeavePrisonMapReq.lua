local CLeavePrisonMapReq = class("CLeavePrisonMapReq")
CLeavePrisonMapReq.TYPEID = 12620047
function CLeavePrisonMapReq:ctor()
  self.id = 12620047
end
function CLeavePrisonMapReq:marshal(os)
end
function CLeavePrisonMapReq:unmarshal(os)
end
function CLeavePrisonMapReq:sizepolicy(size)
  return size <= 65535
end
return CLeavePrisonMapReq
