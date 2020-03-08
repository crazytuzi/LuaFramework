local OctetsStream = require("netio.OctetsStream")
local ReceiverGiftInfo = class("ReceiverGiftInfo")
function ReceiverGiftInfo:ctor(receive_available, sender2receiver_count)
  self.receive_available = receive_available or nil
  self.sender2receiver_count = sender2receiver_count or nil
end
function ReceiverGiftInfo:marshal(os)
  os:marshalInt32(self.receive_available)
  os:marshalInt32(self.sender2receiver_count)
end
function ReceiverGiftInfo:unmarshal(os)
  self.receive_available = os:unmarshalInt32()
  self.sender2receiver_count = os:unmarshalInt32()
end
return ReceiverGiftInfo
