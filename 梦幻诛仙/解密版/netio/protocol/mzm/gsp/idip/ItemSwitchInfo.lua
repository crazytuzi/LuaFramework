local OctetsStream = require("netio.OctetsStream")
local ItemSwitchInfo = class("ItemSwitchInfo")
ItemSwitchInfo.WING = 1
ItemSwitchInfo.MAGIC_MARK = 2
ItemSwitchInfo.FASHION = 3
ItemSwitchInfo.MOUNTS = 4
ItemSwitchInfo.CHANGE_MODEL_CARD = 5
ItemSwitchInfo.AIRCRAFT = 6
ItemSwitchInfo.MIN_TYPE_ID = 1
ItemSwitchInfo.MAX_TYPE_ID = 6
function ItemSwitchInfo:ctor(item_type, cfgid, isopen)
  self.item_type = item_type or nil
  self.cfgid = cfgid or nil
  self.isopen = isopen or nil
end
function ItemSwitchInfo:marshal(os)
  os:marshalInt32(self.item_type)
  os:marshalInt32(self.cfgid)
  os:marshalUInt8(self.isopen)
end
function ItemSwitchInfo:unmarshal(os)
  self.item_type = os:unmarshalInt32()
  self.cfgid = os:unmarshalInt32()
  self.isopen = os:unmarshalUInt8()
end
return ItemSwitchInfo
