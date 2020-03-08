local CInstanceFightReq = class("CInstanceFightReq")
CInstanceFightReq.TYPEID = 12591377
function CInstanceFightReq:ctor(monsterInstanceid)
  self.id = 12591377
  self.monsterInstanceid = monsterInstanceid or nil
end
function CInstanceFightReq:marshal(os)
  os:marshalInt32(self.monsterInstanceid)
end
function CInstanceFightReq:unmarshal(os)
  self.monsterInstanceid = os:unmarshalInt32()
end
function CInstanceFightReq:sizepolicy(size)
  return size <= 65535
end
return CInstanceFightReq
