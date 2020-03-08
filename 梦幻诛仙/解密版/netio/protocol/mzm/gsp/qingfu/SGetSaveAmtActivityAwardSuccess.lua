local SGetSaveAmtActivityAwardSuccess = class("SGetSaveAmtActivityAwardSuccess")
SGetSaveAmtActivityAwardSuccess.TYPEID = 12588812
function SGetSaveAmtActivityAwardSuccess:ctor(activity_id, sort_id)
  self.id = 12588812
  self.activity_id = activity_id or nil
  self.sort_id = sort_id or nil
end
function SGetSaveAmtActivityAwardSuccess:marshal(os)
  os:marshalInt32(self.activity_id)
  os:marshalInt32(self.sort_id)
end
function SGetSaveAmtActivityAwardSuccess:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.sort_id = os:unmarshalInt32()
end
function SGetSaveAmtActivityAwardSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetSaveAmtActivityAwardSuccess
