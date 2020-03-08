local CGetReceiveFlowerPointRankReq = class("CGetReceiveFlowerPointRankReq")
CGetReceiveFlowerPointRankReq.TYPEID = 12584796
function CGetReceiveFlowerPointRankReq:ctor(startpos, num)
  self.id = 12584796
  self.startpos = startpos or nil
  self.num = num or nil
end
function CGetReceiveFlowerPointRankReq:marshal(os)
  os:marshalInt32(self.startpos)
  os:marshalInt32(self.num)
end
function CGetReceiveFlowerPointRankReq:unmarshal(os)
  self.startpos = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
end
function CGetReceiveFlowerPointRankReq:sizepolicy(size)
  return size <= 65535
end
return CGetReceiveFlowerPointRankReq
