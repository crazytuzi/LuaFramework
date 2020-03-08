local SZheyaoAwardCountToMaxRes = class("SZheyaoAwardCountToMaxRes")
SZheyaoAwardCountToMaxRes.TYPEID = 12587584
function SZheyaoAwardCountToMaxRes:ctor(totalCount)
  self.id = 12587584
  self.totalCount = totalCount or nil
end
function SZheyaoAwardCountToMaxRes:marshal(os)
  os:marshalInt32(self.totalCount)
end
function SZheyaoAwardCountToMaxRes:unmarshal(os)
  self.totalCount = os:unmarshalInt32()
end
function SZheyaoAwardCountToMaxRes:sizepolicy(size)
  return size <= 65535
end
return SZheyaoAwardCountToMaxRes
