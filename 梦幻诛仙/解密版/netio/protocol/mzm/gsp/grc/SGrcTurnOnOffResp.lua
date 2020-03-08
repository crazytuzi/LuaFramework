local SGrcTurnOnOffResp = class("SGrcTurnOnOffResp")
SGrcTurnOnOffResp.TYPEID = 12600325
function SGrcTurnOnOffResp:ctor(retcode, gift_type, onoff)
  self.id = 12600325
  self.retcode = retcode or nil
  self.gift_type = gift_type or nil
  self.onoff = onoff or nil
end
function SGrcTurnOnOffResp:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalInt32(self.gift_type)
  os:marshalUInt8(self.onoff)
end
function SGrcTurnOnOffResp:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.gift_type = os:unmarshalInt32()
  self.onoff = os:unmarshalUInt8()
end
function SGrcTurnOnOffResp:sizepolicy(size)
  return size <= 65535
end
return SGrcTurnOnOffResp
