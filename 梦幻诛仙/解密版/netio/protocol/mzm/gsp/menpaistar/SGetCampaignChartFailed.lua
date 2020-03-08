local SGetCampaignChartFailed = class("SGetCampaignChartFailed")
SGetCampaignChartFailed.TYPEID = 12612381
SGetCampaignChartFailed.ERROR_NOT_CAMPAIGN = -1
SGetCampaignChartFailed.ERROR_SWITH_OCCUPATION = -2
function SGetCampaignChartFailed:ctor(target_roleid, retcode)
  self.id = 12612381
  self.target_roleid = target_roleid or nil
  self.retcode = retcode or nil
end
function SGetCampaignChartFailed:marshal(os)
  os:marshalInt64(self.target_roleid)
  os:marshalInt32(self.retcode)
end
function SGetCampaignChartFailed:unmarshal(os)
  self.target_roleid = os:unmarshalInt64()
  self.retcode = os:unmarshalInt32()
end
function SGetCampaignChartFailed:sizepolicy(size)
  return size <= 65535
end
return SGetCampaignChartFailed
