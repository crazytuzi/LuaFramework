local OctetsStream = require("netio.OctetsStream")
local GrcReceiveGiftInfo = class("GrcReceiveGiftInfo")
function GrcReceiveGiftInfo:ctor(gift_type, serialid, from, from_nickname, from_figure_url, count, timestamp)
  self.gift_type = gift_type or nil
  self.serialid = serialid or nil
  self.from = from or nil
  self.from_nickname = from_nickname or nil
  self.from_figure_url = from_figure_url or nil
  self.count = count or nil
  self.timestamp = timestamp or nil
end
function GrcReceiveGiftInfo:marshal(os)
  os:marshalInt32(self.gift_type)
  os:marshalInt64(self.serialid)
  os:marshalOctets(self.from)
  os:marshalOctets(self.from_nickname)
  os:marshalOctets(self.from_figure_url)
  os:marshalInt32(self.count)
  os:marshalInt32(self.timestamp)
end
function GrcReceiveGiftInfo:unmarshal(os)
  self.gift_type = os:unmarshalInt32()
  self.serialid = os:unmarshalInt64()
  self.from = os:unmarshalOctets()
  self.from_nickname = os:unmarshalOctets()
  self.from_figure_url = os:unmarshalOctets()
  self.count = os:unmarshalInt32()
  self.timestamp = os:unmarshalInt32()
end
return GrcReceiveGiftInfo
