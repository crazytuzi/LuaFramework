local SGetGangListRes = class("SGetGangListRes")
SGetGangListRes.TYPEID = 12589861
function SGetGangListRes:ctor(gangList)
  self.id = 12589861
  self.gangList = gangList or {}
end
function SGetGangListRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.gangList))
  for _, v in ipairs(self.gangList) do
    v:marshal(os)
  end
end
function SGetGangListRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.gang.GangInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.gangList, v)
  end
end
function SGetGangListRes:sizepolicy(size)
  return size <= 65535
end
return SGetGangListRes
