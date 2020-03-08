local SGetRoleFightValueRankRes = class("SGetRoleFightValueRankRes")
SGetRoleFightValueRankRes.TYPEID = 12586021
function SGetRoleFightValueRankRes:ctor(rankList, myNo)
  self.id = 12586021
  self.rankList = rankList or {}
  self.myNo = myNo or nil
end
function SGetRoleFightValueRankRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.rankList))
  for _, v in ipairs(self.rankList) do
    v:marshal(os)
  end
  os:marshalInt32(self.myNo)
end
function SGetRoleFightValueRankRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.role.RoleFightValueRankData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.rankList, v)
  end
  self.myNo = os:unmarshalInt32()
end
function SGetRoleFightValueRankRes:sizepolicy(size)
  return size <= 65535
end
return SGetRoleFightValueRankRes
