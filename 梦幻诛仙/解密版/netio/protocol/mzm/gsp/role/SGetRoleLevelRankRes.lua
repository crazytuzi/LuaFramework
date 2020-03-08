local SGetRoleLevelRankRes = class("SGetRoleLevelRankRes")
SGetRoleLevelRankRes.TYPEID = 12586020
function SGetRoleLevelRankRes:ctor(rankList, myNo)
  self.id = 12586020
  self.rankList = rankList or {}
  self.myNo = myNo or nil
end
function SGetRoleLevelRankRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.rankList))
  for _, v in ipairs(self.rankList) do
    v:marshal(os)
  end
  os:marshalInt32(self.myNo)
end
function SGetRoleLevelRankRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.role.RoleLevelRankData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.rankList, v)
  end
  self.myNo = os:unmarshalInt32()
end
function SGetRoleLevelRankRes:sizepolicy(size)
  return size <= 65535
end
return SGetRoleLevelRankRes
