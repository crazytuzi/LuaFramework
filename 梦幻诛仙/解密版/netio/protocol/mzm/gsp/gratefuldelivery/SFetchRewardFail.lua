local SFetchRewardFail = class("SFetchRewardFail")
SFetchRewardFail.TYPEID = 12615687
SFetchRewardFail.UNAVAILABLE = 1
SFetchRewardFail.ALREADY_FETCHED = 2
function SFetchRewardFail:ctor(retcode, stage, activity_id)
  self.id = 12615687
  self.retcode = retcode or nil
  self.stage = stage or nil
  self.activity_id = activity_id or nil
end
function SFetchRewardFail:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalInt32(self.stage)
  os:marshalInt32(self.activity_id)
end
function SFetchRewardFail:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.stage = os:unmarshalInt32()
  self.activity_id = os:unmarshalInt32()
end
function SFetchRewardFail:sizepolicy(size)
  return size <= 65535
end
return SFetchRewardFail
