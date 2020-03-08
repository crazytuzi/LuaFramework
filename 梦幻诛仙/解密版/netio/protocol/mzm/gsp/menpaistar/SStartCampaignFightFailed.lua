local SStartCampaignFightFailed = class("SStartCampaignFightFailed")
SStartCampaignFightFailed.TYPEID = 12612355
SStartCampaignFightFailed.ERROR_LEVEL = -1
SStartCampaignFightFailed.ERROR_LEVEL_LESS_SERVER = -2
SStartCampaignFightFailed.ERROR_FIGHT_NUM_LIMIT = -3
SStartCampaignFightFailed.ERROR_SUCCESSED = -4
SStartCampaignFightFailed.ERROR_IN_TEAM = -5
SStartCampaignFightFailed.ERROR_CANNOT_JOIN_ACTIVITY = -6
SStartCampaignFightFailed.ERROR_ACTIVITY_IN_AWARD = -7
function SStartCampaignFightFailed:ctor(retcode)
  self.id = 12612355
  self.retcode = retcode or nil
end
function SStartCampaignFightFailed:marshal(os)
  os:marshalInt32(self.retcode)
end
function SStartCampaignFightFailed:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function SStartCampaignFightFailed:sizepolicy(size)
  return size <= 65535
end
return SStartCampaignFightFailed
