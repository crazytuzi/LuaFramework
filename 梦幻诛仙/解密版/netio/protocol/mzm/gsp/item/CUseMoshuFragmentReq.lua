local CUseMoshuFragmentReq = class("CUseMoshuFragmentReq")
CUseMoshuFragmentReq.TYPEID = 12584845
function CUseMoshuFragmentReq:ctor(itemId, exchangeType)
  self.id = 12584845
  self.itemId = itemId or nil
  self.exchangeType = exchangeType or nil
end
function CUseMoshuFragmentReq:marshal(os)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.exchangeType)
end
function CUseMoshuFragmentReq:unmarshal(os)
  self.itemId = os:unmarshalInt32()
  self.exchangeType = os:unmarshalInt32()
end
function CUseMoshuFragmentReq:sizepolicy(size)
  return size <= 65535
end
return CUseMoshuFragmentReq
