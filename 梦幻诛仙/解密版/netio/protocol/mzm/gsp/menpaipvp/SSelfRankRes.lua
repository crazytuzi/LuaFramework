local SSelfRankRes = class("SSelfRankRes")
SSelfRankRes.TYPEID = 12596231
function SSelfRankRes:ctor(rank)
  self.id = 12596231
  self.rank = rank or nil
end
function SSelfRankRes:marshal(os)
  os:marshalInt32(self.rank)
end
function SSelfRankRes:unmarshal(os)
  self.rank = os:unmarshalInt32()
end
function SSelfRankRes:sizepolicy(size)
  return size <= 65535
end
return SSelfRankRes
