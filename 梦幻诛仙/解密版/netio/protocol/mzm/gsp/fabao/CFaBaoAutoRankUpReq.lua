local CFaBaoAutoRankUpReq = class("CFaBaoAutoRankUpReq")
CFaBaoAutoRankUpReq.TYPEID = 12596041
function CFaBaoAutoRankUpReq:ctor(equiped, fabaouuid, upToRank, bagId2CostInfo, useYuanbaoNum)
  self.id = 12596041
  self.equiped = equiped or nil
  self.fabaouuid = fabaouuid or nil
  self.upToRank = upToRank or nil
  self.bagId2CostInfo = bagId2CostInfo or {}
  self.useYuanbaoNum = useYuanbaoNum or nil
end
function CFaBaoAutoRankUpReq:marshal(os)
  os:marshalInt32(self.equiped)
  os:marshalInt64(self.fabaouuid)
  os:marshalInt32(self.upToRank)
  do
    local _size_ = 0
    for _, _ in pairs(self.bagId2CostInfo) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.bagId2CostInfo) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  os:marshalInt32(self.useYuanbaoNum)
end
function CFaBaoAutoRankUpReq:unmarshal(os)
  self.equiped = os:unmarshalInt32()
  self.fabaouuid = os:unmarshalInt64()
  self.upToRank = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.fabao.CostInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.bagId2CostInfo[k] = v
  end
  self.useYuanbaoNum = os:unmarshalInt32()
end
function CFaBaoAutoRankUpReq:sizepolicy(size)
  return size <= 65535
end
return CFaBaoAutoRankUpReq
