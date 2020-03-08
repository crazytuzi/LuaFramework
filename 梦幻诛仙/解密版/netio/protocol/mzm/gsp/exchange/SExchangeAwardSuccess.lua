local SExchangeAwardSuccess = class("SExchangeAwardSuccess")
SExchangeAwardSuccess.TYPEID = 12604164
function SExchangeAwardSuccess:ctor(activity_cfg_id, sort_id, already_exchange_times)
  self.id = 12604164
  self.activity_cfg_id = activity_cfg_id or nil
  self.sort_id = sort_id or nil
  self.already_exchange_times = already_exchange_times or nil
end
function SExchangeAwardSuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.sort_id)
  os:marshalInt32(self.already_exchange_times)
end
function SExchangeAwardSuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.sort_id = os:unmarshalInt32()
  self.already_exchange_times = os:unmarshalInt32()
end
function SExchangeAwardSuccess:sizepolicy(size)
  return size <= 65535
end
return SExchangeAwardSuccess
