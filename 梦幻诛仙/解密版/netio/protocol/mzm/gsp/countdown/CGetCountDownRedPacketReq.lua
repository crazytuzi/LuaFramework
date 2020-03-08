local CGetCountDownRedPacketReq = class("CGetCountDownRedPacketReq")
CGetCountDownRedPacketReq.TYPEID = 12606723
function CGetCountDownRedPacketReq:ctor(cfg_id)
  self.id = 12606723
  self.cfg_id = cfg_id or nil
end
function CGetCountDownRedPacketReq:marshal(os)
  os:marshalInt32(self.cfg_id)
end
function CGetCountDownRedPacketReq:unmarshal(os)
  self.cfg_id = os:unmarshalInt32()
end
function CGetCountDownRedPacketReq:sizepolicy(size)
  return size <= 65535
end
return CGetCountDownRedPacketReq
