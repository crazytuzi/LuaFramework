local SGetCombineGangListRes = class("SGetCombineGangListRes")
SGetCombineGangListRes.TYPEID = 12589958
function SGetCombineGangListRes:ctor(gangs)
  self.id = 12589958
  self.gangs = gangs or {}
end
function SGetCombineGangListRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.gangs))
  for _, v in ipairs(self.gangs) do
    v:marshal(os)
  end
end
function SGetCombineGangListRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.gang.CombineGang")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.gangs, v)
  end
end
function SGetCombineGangListRes:sizepolicy(size)
  return size <= 65535
end
return SGetCombineGangListRes
