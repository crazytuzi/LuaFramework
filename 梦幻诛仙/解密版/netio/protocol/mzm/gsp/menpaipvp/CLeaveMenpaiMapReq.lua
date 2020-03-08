local CLeaveMenpaiMapReq = class("CLeaveMenpaiMapReq")
CLeaveMenpaiMapReq.TYPEID = 12596228
function CLeaveMenpaiMapReq:ctor()
  self.id = 12596228
end
function CLeaveMenpaiMapReq:marshal(os)
end
function CLeaveMenpaiMapReq:unmarshal(os)
end
function CLeaveMenpaiMapReq:sizepolicy(size)
  return size <= 65535
end
return CLeaveMenpaiMapReq
