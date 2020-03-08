local CGetGiveFlowerPointRankReq = class("CGetGiveFlowerPointRankReq")
CGetGiveFlowerPointRankReq.TYPEID = 12584799
function CGetGiveFlowerPointRankReq:ctor(startpos, num)
  self.id = 12584799
  self.startpos = startpos or nil
  self.num = num or nil
end
function CGetGiveFlowerPointRankReq:marshal(os)
  os:marshalInt32(self.startpos)
  os:marshalInt32(self.num)
end
function CGetGiveFlowerPointRankReq:unmarshal(os)
  self.startpos = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
end
function CGetGiveFlowerPointRankReq:sizepolicy(size)
  return size <= 65535
end
return CGetGiveFlowerPointRankReq
