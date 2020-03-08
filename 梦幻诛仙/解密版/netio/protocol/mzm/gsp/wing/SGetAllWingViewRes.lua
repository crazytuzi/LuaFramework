local SGetAllWingViewRes = class("SGetAllWingViewRes")
SGetAllWingViewRes.TYPEID = 12596504
function SGetAllWingViewRes:ctor(index, modelids)
  self.id = 12596504
  self.index = index or nil
  self.modelids = modelids or {}
end
function SGetAllWingViewRes:marshal(os)
  os:marshalInt32(self.index)
  os:marshalCompactUInt32(table.getn(self.modelids))
  for _, v in ipairs(self.modelids) do
    v:marshal(os)
  end
end
function SGetAllWingViewRes:unmarshal(os)
  self.index = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.wing.ModelId2DyeId")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.modelids, v)
  end
end
function SGetAllWingViewRes:sizepolicy(size)
  return size <= 65535
end
return SGetAllWingViewRes
