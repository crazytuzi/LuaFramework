local CExchangeAwardReq = class("CExchangeAwardReq")
CExchangeAwardReq.TYPEID = 12604163
function CExchangeAwardReq:ctor(activity_cfg_id, sort_id, exchange_times)
  self.id = 12604163
  self.activity_cfg_id = activity_cfg_id or nil
  self.sort_id = sort_id or nil
  self.exchange_times = exchange_times or nil
end
function CExchangeAwardReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.sort_id)
  os:marshalInt32(self.exchange_times)
end
function CExchangeAwardReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.sort_id = os:unmarshalInt32()
  self.exchange_times = os:unmarshalInt32()
end
function CExchangeAwardReq:sizepolicy(size)
  return size <= 65535
end
return CExchangeAwardReq
