local SGetOccupationMFVRankRes = class("SGetOccupationMFVRankRes")
SGetOccupationMFVRankRes.TYPEID = 12586030
function SGetOccupationMFVRankRes:ctor(occupationId, rankList, myNo, myValue)
  self.id = 12586030
  self.occupationId = occupationId or nil
  self.rankList = rankList or {}
  self.myNo = myNo or nil
  self.myValue = myValue or nil
end
function SGetOccupationMFVRankRes:marshal(os)
  os:marshalInt32(self.occupationId)
  os:marshalCompactUInt32(table.getn(self.rankList))
  for _, v in ipairs(self.rankList) do
    v:marshal(os)
  end
  os:marshalInt32(self.myNo)
  os:marshalInt32(self.myValue)
end
function SGetOccupationMFVRankRes:unmarshal(os)
  self.occupationId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.role.RoleMFVRankData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.rankList, v)
  end
  self.myNo = os:unmarshalInt32()
  self.myValue = os:unmarshalInt32()
end
function SGetOccupationMFVRankRes:sizepolicy(size)
  return size <= 65535
end
return SGetOccupationMFVRankRes
