local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local SSynEquipQiLinOperateRes = class("SSynEquipQiLinOperateRes")
SSynEquipQiLinOperateRes.TYPEID = 12584855
function SSynEquipQiLinOperateRes:ctor(strengthLevel, iteminfo)
  self.id = 12584855
  self.strengthLevel = strengthLevel or nil
  self.iteminfo = iteminfo or ItemInfo.new()
end
function SSynEquipQiLinOperateRes:marshal(os)
  os:marshalInt32(self.strengthLevel)
  self.iteminfo:marshal(os)
end
function SSynEquipQiLinOperateRes:unmarshal(os)
  self.strengthLevel = os:unmarshalInt32()
  self.iteminfo = ItemInfo.new()
  self.iteminfo:unmarshal(os)
end
function SSynEquipQiLinOperateRes:sizepolicy(size)
  return size <= 65535
end
return SSynEquipQiLinOperateRes
