local CLeaveLadderReq = class("CLeaveLadderReq")
CLeaveLadderReq.TYPEID = 12607248
function CLeaveLadderReq:ctor()
  self.id = 12607248
end
function CLeaveLadderReq:marshal(os)
end
function CLeaveLadderReq:unmarshal(os)
end
function CLeaveLadderReq:sizepolicy(size)
  return size <= 65535
end
return CLeaveLadderReq
