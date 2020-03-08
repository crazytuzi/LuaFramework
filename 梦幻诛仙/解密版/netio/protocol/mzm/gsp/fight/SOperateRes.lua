local SOperateRes = class("SOperateRes")
SOperateRes.TYPEID = 12594182
function SOperateRes:ctor(fighterid)
  self.id = 12594182
  self.fighterid = fighterid or nil
end
function SOperateRes:marshal(os)
  os:marshalInt32(self.fighterid)
end
function SOperateRes:unmarshal(os)
  self.fighterid = os:unmarshalInt32()
end
function SOperateRes:sizepolicy(size)
  return size <= 65535
end
return SOperateRes
