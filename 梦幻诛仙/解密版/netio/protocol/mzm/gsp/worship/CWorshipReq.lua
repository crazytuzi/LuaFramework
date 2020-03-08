local CWorshipReq = class("CWorshipReq")
CWorshipReq.TYPEID = 12612611
function CWorshipReq:ctor(worshipId)
  self.id = 12612611
  self.worshipId = worshipId or nil
end
function CWorshipReq:marshal(os)
  os:marshalInt32(self.worshipId)
end
function CWorshipReq:unmarshal(os)
  self.worshipId = os:unmarshalInt32()
end
function CWorshipReq:sizepolicy(size)
  return size <= 65535
end
return CWorshipReq
