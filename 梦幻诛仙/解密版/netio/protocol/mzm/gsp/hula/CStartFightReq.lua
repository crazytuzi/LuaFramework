local CStartFightReq = class("CStartFightReq")
CStartFightReq.TYPEID = 12608778
function CStartFightReq:ctor(seq)
  self.id = 12608778
  self.seq = seq or nil
end
function CStartFightReq:marshal(os)
  os:marshalInt32(self.seq)
end
function CStartFightReq:unmarshal(os)
  self.seq = os:unmarshalInt32()
end
function CStartFightReq:sizepolicy(size)
  return size <= 65535
end
return CStartFightReq
