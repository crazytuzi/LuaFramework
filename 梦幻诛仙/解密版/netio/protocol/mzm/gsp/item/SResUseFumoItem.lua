local EquipFumoInfo = require("netio.protocol.mzm.gsp.item.EquipFumoInfo")
local SResUseFumoItem = class("SResUseFumoItem")
SResUseFumoItem.TYPEID = 12584762
function SResUseFumoItem:ctor(equipfumoinfo)
  self.id = 12584762
  self.equipfumoinfo = equipfumoinfo or EquipFumoInfo.new()
end
function SResUseFumoItem:marshal(os)
  self.equipfumoinfo:marshal(os)
end
function SResUseFumoItem:unmarshal(os)
  self.equipfumoinfo = EquipFumoInfo.new()
  self.equipfumoinfo:unmarshal(os)
end
function SResUseFumoItem:sizepolicy(size)
  return size <= 65535
end
return SResUseFumoItem
