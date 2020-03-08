local SGetRoleJingjiRankRes = class("SGetRoleJingjiRankRes")
SGetRoleJingjiRankRes.TYPEID = 12595727
function SGetRoleJingjiRankRes:ctor(point, myrank, rankList)
  self.id = 12595727
  self.point = point or nil
  self.myrank = myrank or nil
  self.rankList = rankList or {}
end
function SGetRoleJingjiRankRes:marshal(os)
  os:marshalInt32(self.point)
  os:marshalInt32(self.myrank)
  os:marshalCompactUInt32(table.getn(self.rankList))
  for _, v in ipairs(self.rankList) do
    v:marshal(os)
  end
end
function SGetRoleJingjiRankRes:unmarshal(os)
  self.point = os:unmarshalInt32()
  self.myrank = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.jingji.RoleJingjiRankData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.rankList, v)
  end
end
function SGetRoleJingjiRankRes:sizepolicy(size)
  return size <= 65535
end
return SGetRoleJingjiRankRes
