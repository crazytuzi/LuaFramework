local SSurrenderSuccessRep = class("SSurrenderSuccessRep")
SSurrenderSuccessRep.TYPEID = 12619037
function SSurrenderSuccessRep:ctor()
  self.id = 12619037
end
function SSurrenderSuccessRep:marshal(os)
end
function SSurrenderSuccessRep:unmarshal(os)
end
function SSurrenderSuccessRep:sizepolicy(size)
  return size <= 65535
end
return SSurrenderSuccessRep
