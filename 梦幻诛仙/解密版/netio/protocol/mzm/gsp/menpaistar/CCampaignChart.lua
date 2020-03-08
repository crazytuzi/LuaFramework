local CCampaignChart = class("CCampaignChart")
CCampaignChart.TYPEID = 12612369
function CCampaignChart:ctor(occupationid, page)
  self.id = 12612369
  self.occupationid = occupationid or nil
  self.page = page or nil
end
function CCampaignChart:marshal(os)
  os:marshalInt32(self.occupationid)
  os:marshalInt32(self.page)
end
function CCampaignChart:unmarshal(os)
  self.occupationid = os:unmarshalInt32()
  self.page = os:unmarshalInt32()
end
function CCampaignChart:sizepolicy(size)
  return size <= 65535
end
return CCampaignChart
