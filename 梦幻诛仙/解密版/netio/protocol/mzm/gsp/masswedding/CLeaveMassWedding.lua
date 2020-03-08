local CLeaveMassWedding = class("CLeaveMassWedding")
CLeaveMassWedding.TYPEID = 12604950
function CLeaveMassWedding:ctor()
  self.id = 12604950
end
function CLeaveMassWedding:marshal(os)
end
function CLeaveMassWedding:unmarshal(os)
end
function CLeaveMassWedding:sizepolicy(size)
  return size <= 65535
end
return CLeaveMassWedding
