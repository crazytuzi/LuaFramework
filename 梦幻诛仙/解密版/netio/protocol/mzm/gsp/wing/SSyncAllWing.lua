local SSyncAllWing = class("SSyncAllWing")
SSyncAllWing.TYPEID = 12596487
function SSyncAllWing:ctor(WingList, curIndex, isshowwing)
  self.id = 12596487
  self.WingList = WingList or {}
  self.curIndex = curIndex or nil
  self.isshowwing = isshowwing or nil
end
function SSyncAllWing:marshal(os)
  os:marshalCompactUInt32(table.getn(self.WingList))
  for _, v in ipairs(self.WingList) do
    v:marshal(os)
  end
  os:marshalInt32(self.curIndex)
  os:marshalInt32(self.isshowwing)
end
function SSyncAllWing:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.wing.WingInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.WingList, v)
  end
  self.curIndex = os:unmarshalInt32()
  self.isshowwing = os:unmarshalInt32()
end
function SSyncAllWing:sizepolicy(size)
  return size <= 65535
end
return SSyncAllWing
