local CQMHWRankReq = class("CQMHWRankReq")
CQMHWRankReq.TYPEID = 12601867
function CQMHWRankReq:ctor(fromNo, toNo)
  self.id = 12601867
  self.fromNo = fromNo or nil
  self.toNo = toNo or nil
end
function CQMHWRankReq:marshal(os)
  os:marshalInt32(self.fromNo)
  os:marshalInt32(self.toNo)
end
function CQMHWRankReq:unmarshal(os)
  self.fromNo = os:unmarshalInt32()
  self.toNo = os:unmarshalInt32()
end
function CQMHWRankReq:sizepolicy(size)
  return size <= 65535
end
return CQMHWRankReq
