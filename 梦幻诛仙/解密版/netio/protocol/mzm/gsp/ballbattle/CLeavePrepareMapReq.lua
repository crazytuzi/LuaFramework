local CLeavePrepareMapReq = class("CLeavePrepareMapReq")
CLeavePrepareMapReq.TYPEID = 12629263
function CLeavePrepareMapReq:ctor()
  self.id = 12629263
end
function CLeavePrepareMapReq:marshal(os)
end
function CLeavePrepareMapReq:unmarshal(os)
end
function CLeavePrepareMapReq:sizepolicy(size)
  return size <= 65535
end
return CLeavePrepareMapReq
