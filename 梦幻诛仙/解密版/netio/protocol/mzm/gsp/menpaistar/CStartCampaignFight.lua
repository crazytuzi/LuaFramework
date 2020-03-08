local CStartCampaignFight = class("CStartCampaignFight")
CStartCampaignFight.TYPEID = 12612361
function CStartCampaignFight:ctor()
  self.id = 12612361
end
function CStartCampaignFight:marshal(os)
end
function CStartCampaignFight:unmarshal(os)
end
function CStartCampaignFight:sizepolicy(size)
  return size <= 65535
end
return CStartCampaignFight
