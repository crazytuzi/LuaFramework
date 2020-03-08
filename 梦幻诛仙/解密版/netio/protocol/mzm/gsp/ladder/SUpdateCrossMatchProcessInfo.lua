local SUpdateCrossMatchProcessInfo = class("SUpdateCrossMatchProcessInfo")
SUpdateCrossMatchProcessInfo.TYPEID = 12607255
function SUpdateCrossMatchProcessInfo:ctor(crossMatchProcessInfos)
  self.id = 12607255
  self.crossMatchProcessInfos = crossMatchProcessInfos or {}
end
function SUpdateCrossMatchProcessInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.crossMatchProcessInfos))
  for _, v in ipairs(self.crossMatchProcessInfos) do
    v:marshal(os)
  end
end
function SUpdateCrossMatchProcessInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.ladder.CrossMatchProcessInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.crossMatchProcessInfos, v)
  end
end
function SUpdateCrossMatchProcessInfo:sizepolicy(size)
  return size <= 65535
end
return SUpdateCrossMatchProcessInfo
