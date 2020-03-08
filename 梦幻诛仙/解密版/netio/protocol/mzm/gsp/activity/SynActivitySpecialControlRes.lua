local SynActivitySpecialControlRes = class("SynActivitySpecialControlRes")
SynActivitySpecialControlRes.TYPEID = 12587602
function SynActivitySpecialControlRes:ctor(specialControlDatas)
  self.id = 12587602
  self.specialControlDatas = specialControlDatas or {}
end
function SynActivitySpecialControlRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.specialControlDatas))
  for _, v in ipairs(self.specialControlDatas) do
    v:marshal(os)
  end
end
function SynActivitySpecialControlRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.activity.SpecialControlData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.specialControlDatas, v)
  end
end
function SynActivitySpecialControlRes:sizepolicy(size)
  return size <= 65535
end
return SynActivitySpecialControlRes
