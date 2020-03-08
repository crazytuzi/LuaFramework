local SGetSaveAmtActivityAwardFailed = class("SGetSaveAmtActivityAwardFailed")
SGetSaveAmtActivityAwardFailed.TYPEID = 12588814
SGetSaveAmtActivityAwardFailed.ERROR_ACTVITY_NOT_OPEN = -1
SGetSaveAmtActivityAwardFailed.ERROR_SAVE_AMT_NOT_MEET = -2
SGetSaveAmtActivityAwardFailed.ERROR_ALREADY_GET_AWARD = -3
function SGetSaveAmtActivityAwardFailed:ctor(activity_id, sortid, retcode)
  self.id = 12588814
  self.activity_id = activity_id or nil
  self.sortid = sortid or nil
  self.retcode = retcode or nil
end
function SGetSaveAmtActivityAwardFailed:marshal(os)
  os:marshalInt32(self.activity_id)
  os:marshalInt32(self.sortid)
  os:marshalInt32(self.retcode)
end
function SGetSaveAmtActivityAwardFailed:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.sortid = os:unmarshalInt32()
  self.retcode = os:unmarshalInt32()
end
function SGetSaveAmtActivityAwardFailed:sizepolicy(size)
  return size <= 65535
end
return SGetSaveAmtActivityAwardFailed
