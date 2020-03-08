local CRandomLuckyBlesserReq = class("CRandomLuckyBlesserReq")
CRandomLuckyBlesserReq.TYPEID = 12604941
function CRandomLuckyBlesserReq:ctor()
  self.id = 12604941
end
function CRandomLuckyBlesserReq:marshal(os)
end
function CRandomLuckyBlesserReq:unmarshal(os)
end
function CRandomLuckyBlesserReq:sizepolicy(size)
  return size <= 65535
end
return CRandomLuckyBlesserReq
