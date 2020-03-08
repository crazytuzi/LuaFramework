local CUpgradeWuShi = class("CUpgradeWuShi")
CUpgradeWuShi.TYPEID = 12618779
CUpgradeWuShi.consume_all = 1
CUpgradeWuShi.consume_one = 2
function CUpgradeWuShi:ctor(itemCfgId, wuShiCfgId, consumeType)
  self.id = 12618779
  self.itemCfgId = itemCfgId or nil
  self.wuShiCfgId = wuShiCfgId or nil
  self.consumeType = consumeType or nil
end
function CUpgradeWuShi:marshal(os)
  os:marshalInt32(self.itemCfgId)
  os:marshalInt32(self.wuShiCfgId)
  os:marshalInt32(self.consumeType)
end
function CUpgradeWuShi:unmarshal(os)
  self.itemCfgId = os:unmarshalInt32()
  self.wuShiCfgId = os:unmarshalInt32()
  self.consumeType = os:unmarshalInt32()
end
function CUpgradeWuShi:sizepolicy(size)
  return size <= 65535
end
return CUpgradeWuShi
