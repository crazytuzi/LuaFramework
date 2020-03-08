local CGetSellPetNumReq = class("CGetSellPetNumReq")
CGetSellPetNumReq.TYPEID = 12590653
function CGetSellPetNumReq:ctor()
  self.id = 12590653
end
function CGetSellPetNumReq:marshal(os)
end
function CGetSellPetNumReq:unmarshal(os)
end
function CGetSellPetNumReq:sizepolicy(size)
  return size <= 65535
end
return CGetSellPetNumReq
