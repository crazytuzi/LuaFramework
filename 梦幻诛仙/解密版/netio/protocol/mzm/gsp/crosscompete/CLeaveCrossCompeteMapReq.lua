local CLeaveCrossCompeteMapReq = class("CLeaveCrossCompeteMapReq")
CLeaveCrossCompeteMapReq.TYPEID = 12616742
function CLeaveCrossCompeteMapReq:ctor()
  self.id = 12616742
end
function CLeaveCrossCompeteMapReq:marshal(os)
end
function CLeaveCrossCompeteMapReq:unmarshal(os)
end
function CLeaveCrossCompeteMapReq:sizepolicy(size)
  return size <= 65535
end
return CLeaveCrossCompeteMapReq
