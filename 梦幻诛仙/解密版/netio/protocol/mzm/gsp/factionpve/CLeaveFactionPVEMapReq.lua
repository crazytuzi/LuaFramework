local CLeaveFactionPVEMapReq = class("CLeaveFactionPVEMapReq")
CLeaveFactionPVEMapReq.TYPEID = 12613642
function CLeaveFactionPVEMapReq:ctor()
  self.id = 12613642
end
function CLeaveFactionPVEMapReq:marshal(os)
end
function CLeaveFactionPVEMapReq:unmarshal(os)
end
function CLeaveFactionPVEMapReq:sizepolicy(size)
  return size <= 65535
end
return CLeaveFactionPVEMapReq
