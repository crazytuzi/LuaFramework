local SGetCountDownRedPacketSuccess = class("SGetCountDownRedPacketSuccess")
SGetCountDownRedPacketSuccess.TYPEID = 12606721
function SGetCountDownRedPacketSuccess:ctor(cfg_id)
  self.id = 12606721
  self.cfg_id = cfg_id or nil
end
function SGetCountDownRedPacketSuccess:marshal(os)
  os:marshalInt32(self.cfg_id)
end
function SGetCountDownRedPacketSuccess:unmarshal(os)
  self.cfg_id = os:unmarshalInt32()
end
function SGetCountDownRedPacketSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetCountDownRedPacketSuccess
