local SAllMallItemNum = class("SAllMallItemNum")
SAllMallItemNum.TYPEID = 12585475
function SAllMallItemNum:ctor(mallItemList)
  self.id = 12585475
  self.mallItemList = mallItemList or {}
end
function SAllMallItemNum:marshal(os)
  os:marshalCompactUInt32(table.getn(self.mallItemList))
  for _, v in ipairs(self.mallItemList) do
    v:marshal(os)
  end
end
function SAllMallItemNum:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.mall.MallItemInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.mallItemList, v)
  end
end
function SAllMallItemNum:sizepolicy(size)
  return size <= 65535
end
return SAllMallItemNum
