local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local SPacketFaBaoInChatInfo = class("SPacketFaBaoInChatInfo")
SPacketFaBaoInChatInfo.TYPEID = 12585243
function SPacketFaBaoInChatInfo:ctor(checkedroleid, iteminfo)
  self.id = 12585243
  self.checkedroleid = checkedroleid or nil
  self.iteminfo = iteminfo or ItemInfo.new()
end
function SPacketFaBaoInChatInfo:marshal(os)
  os:marshalInt64(self.checkedroleid)
  self.iteminfo:marshal(os)
end
function SPacketFaBaoInChatInfo:unmarshal(os)
  self.checkedroleid = os:unmarshalInt64()
  self.iteminfo = ItemInfo.new()
  self.iteminfo:unmarshal(os)
end
function SPacketFaBaoInChatInfo:sizepolicy(size)
  return size <= 65535
end
return SPacketFaBaoInChatInfo
