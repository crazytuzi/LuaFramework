local SSyncCampaignFightResult = class("SSyncCampaignFightResult")
SSyncCampaignFightResult.TYPEID = 12612382
function SSyncCampaignFightResult:ctor(success)
  self.id = 12612382
  self.success = success or nil
end
function SSyncCampaignFightResult:marshal(os)
  os:marshalUInt8(self.success)
end
function SSyncCampaignFightResult:unmarshal(os)
  self.success = os:unmarshalUInt8()
end
function SSyncCampaignFightResult:sizepolicy(size)
  return size <= 65535
end
return SSyncCampaignFightResult
