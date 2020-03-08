local SynActivityInitRes = class("SynActivityInitRes")
SynActivityInitRes.TYPEID = 12587535
function SynActivityInitRes:ctor(activityInfos)
  self.id = 12587535
  self.activityInfos = activityInfos or {}
end
function SynActivityInitRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.activityInfos))
  for _, v in ipairs(self.activityInfos) do
    v:marshal(os)
  end
end
function SynActivityInitRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.activity.ActivityData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.activityInfos, v)
  end
end
function SynActivityInitRes:sizepolicy(size)
  return size <= 65535
end
return SynActivityInitRes
