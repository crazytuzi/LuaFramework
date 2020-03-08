local CGetCampaignChart = class("CGetCampaignChart")
CGetCampaignChart.TYPEID = 12612353
function CGetCampaignChart:ctor(target_roleid)
  self.id = 12612353
  self.target_roleid = target_roleid or nil
end
function CGetCampaignChart:marshal(os)
  os:marshalInt64(self.target_roleid)
end
function CGetCampaignChart:unmarshal(os)
  self.target_roleid = os:unmarshalInt64()
end
function CGetCampaignChart:sizepolicy(size)
  return size <= 65535
end
return CGetCampaignChart
