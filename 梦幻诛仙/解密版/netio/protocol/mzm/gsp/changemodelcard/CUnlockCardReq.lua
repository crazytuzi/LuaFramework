local CUnlockCardReq = class("CUnlockCardReq")
CUnlockCardReq.TYPEID = 12624385
function CUnlockCardReq:ctor(item_uuid)
  self.id = 12624385
  self.item_uuid = item_uuid or nil
end
function CUnlockCardReq:marshal(os)
  os:marshalInt64(self.item_uuid)
end
function CUnlockCardReq:unmarshal(os)
  self.item_uuid = os:unmarshalInt64()
end
function CUnlockCardReq:sizepolicy(size)
  return size <= 65535
end
return CUnlockCardReq
