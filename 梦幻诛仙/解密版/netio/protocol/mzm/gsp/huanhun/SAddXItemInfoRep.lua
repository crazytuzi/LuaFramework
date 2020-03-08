local ItemInfo = require("netio.protocol.mzm.gsp.huanhun.ItemInfo")
local SAddXItemInfoRep = class("SAddXItemInfoRep")
SAddXItemInfoRep.TYPEID = 12584456
function SAddXItemInfoRep:ctor(roleIdSeekHelp, itemIndex, itemInfo)
  self.id = 12584456
  self.roleIdSeekHelp = roleIdSeekHelp or nil
  self.itemIndex = itemIndex or nil
  self.itemInfo = itemInfo or ItemInfo.new()
end
function SAddXItemInfoRep:marshal(os)
  os:marshalInt64(self.roleIdSeekHelp)
  os:marshalInt32(self.itemIndex)
  self.itemInfo:marshal(os)
end
function SAddXItemInfoRep:unmarshal(os)
  self.roleIdSeekHelp = os:unmarshalInt64()
  self.itemIndex = os:unmarshalInt32()
  self.itemInfo = ItemInfo.new()
  self.itemInfo:unmarshal(os)
end
function SAddXItemInfoRep:sizepolicy(size)
  return size <= 65535
end
return SAddXItemInfoRep
