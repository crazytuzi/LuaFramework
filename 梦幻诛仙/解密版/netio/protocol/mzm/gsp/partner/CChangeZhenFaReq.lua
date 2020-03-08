local CChangeZhenFaReq = class("CChangeZhenFaReq")
CChangeZhenFaReq.TYPEID = 12588042
function CChangeZhenFaReq:ctor(lineUpNum, zhenFaId)
  self.id = 12588042
  self.lineUpNum = lineUpNum or nil
  self.zhenFaId = zhenFaId or nil
end
function CChangeZhenFaReq:marshal(os)
  os:marshalInt32(self.lineUpNum)
  os:marshalInt32(self.zhenFaId)
end
function CChangeZhenFaReq:unmarshal(os)
  self.lineUpNum = os:unmarshalInt32()
  self.zhenFaId = os:unmarshalInt32()
end
function CChangeZhenFaReq:sizepolicy(size)
  return size <= 65535
end
return CChangeZhenFaReq
