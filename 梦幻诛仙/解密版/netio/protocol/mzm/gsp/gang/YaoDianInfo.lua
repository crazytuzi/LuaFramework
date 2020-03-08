local OctetsStream = require("netio.OctetsStream")
local YaoDianInfo = class("YaoDianInfo")
function YaoDianInfo:ctor(level, levelUpEndTime, shopItemList)
  self.level = level or nil
  self.levelUpEndTime = levelUpEndTime or nil
  self.shopItemList = shopItemList or {}
end
function YaoDianInfo:marshal(os)
  os:marshalInt32(self.level)
  os:marshalInt32(self.levelUpEndTime)
  os:marshalCompactUInt32(table.getn(self.shopItemList))
  for _, v in ipairs(self.shopItemList) do
    v:marshal(os)
  end
end
function YaoDianInfo:unmarshal(os)
  self.level = os:unmarshalInt32()
  self.levelUpEndTime = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.gang.YaoCaiShopItem")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.shopItemList, v)
  end
end
return YaoDianInfo
