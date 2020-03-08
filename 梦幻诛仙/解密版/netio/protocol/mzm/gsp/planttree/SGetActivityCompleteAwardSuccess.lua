local SGetActivityCompleteAwardSuccess = class("SGetActivityCompleteAwardSuccess")
SGetActivityCompleteAwardSuccess.TYPEID = 12611590
function SGetActivityCompleteAwardSuccess:ctor(activity_cfg_id)
  self.id = 12611590
  self.activity_cfg_id = activity_cfg_id or nil
end
function SGetActivityCompleteAwardSuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function SGetActivityCompleteAwardSuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function SGetActivityCompleteAwardSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetActivityCompleteAwardSuccess
