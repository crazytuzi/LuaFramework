local CCourtYardLevelUpReq = class("CCourtYardLevelUpReq")
CCourtYardLevelUpReq.TYPEID = 12605511
function CCourtYardLevelUpReq:ctor()
  self.id = 12605511
end
function CCourtYardLevelUpReq:marshal(os)
end
function CCourtYardLevelUpReq:unmarshal(os)
end
function CCourtYardLevelUpReq:sizepolicy(size)
  return size <= 65535
end
return CCourtYardLevelUpReq
