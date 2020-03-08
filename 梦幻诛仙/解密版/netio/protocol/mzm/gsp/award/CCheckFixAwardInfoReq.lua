local CCheckFixAwardInfoReq = class("CCheckFixAwardInfoReq")
CCheckFixAwardInfoReq.TYPEID = 12583425
function CCheckFixAwardInfoReq:ctor(fixAwardId, itemIndex)
  self.id = 12583425
  self.fixAwardId = fixAwardId or nil
  self.itemIndex = itemIndex or nil
end
function CCheckFixAwardInfoReq:marshal(os)
  os:marshalInt32(self.fixAwardId)
  os:marshalInt32(self.itemIndex)
end
function CCheckFixAwardInfoReq:unmarshal(os)
  self.fixAwardId = os:unmarshalInt32()
  self.itemIndex = os:unmarshalInt32()
end
function CCheckFixAwardInfoReq:sizepolicy(size)
  return size <= 65535
end
return CCheckFixAwardInfoReq
