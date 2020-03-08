local SChangeZhenFaReq = class("SChangeZhenFaReq")
SChangeZhenFaReq.TYPEID = 12588035
function SChangeZhenFaReq:ctor(lineUpNum, zhenFaId)
  self.id = 12588035
  self.lineUpNum = lineUpNum or nil
  self.zhenFaId = zhenFaId or nil
end
function SChangeZhenFaReq:marshal(os)
  os:marshalInt32(self.lineUpNum)
  os:marshalInt32(self.zhenFaId)
end
function SChangeZhenFaReq:unmarshal(os)
  self.lineUpNum = os:unmarshalInt32()
  self.zhenFaId = os:unmarshalInt32()
end
function SChangeZhenFaReq:sizepolicy(size)
  return size <= 65535
end
return SChangeZhenFaReq
