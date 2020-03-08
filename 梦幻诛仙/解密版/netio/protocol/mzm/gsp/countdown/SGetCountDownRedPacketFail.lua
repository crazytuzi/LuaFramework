local SGetCountDownRedPacketFail = class("SGetCountDownRedPacketFail")
SGetCountDownRedPacketFail.TYPEID = 12606722
SGetCountDownRedPacketFail.ROLE_HAS_GET_RED_PACKET = 1
SGetCountDownRedPacketFail.ROLE_CANNOT_GET_RED_PACKET = 2
SGetCountDownRedPacketFail.AWARD_FAIL = 3
SGetCountDownRedPacketFail.NOT_IN_GET_RED_PACKET_TIME = 4
function SGetCountDownRedPacketFail:ctor(cfg_id, res)
  self.id = 12606722
  self.cfg_id = cfg_id or nil
  self.res = res or nil
end
function SGetCountDownRedPacketFail:marshal(os)
  os:marshalInt32(self.cfg_id)
  os:marshalInt32(self.res)
end
function SGetCountDownRedPacketFail:unmarshal(os)
  self.cfg_id = os:unmarshalInt32()
  self.res = os:unmarshalInt32()
end
function SGetCountDownRedPacketFail:sizepolicy(size)
  return size <= 65535
end
return SGetCountDownRedPacketFail
