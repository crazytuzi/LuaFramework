require "Core.Module.Common.UIItem"


local CloudPurchaseRecoderItem = class("CloudPurchaseRecoderItem", UIItem);
local CloudPurchaseRewardItem = require "Core.Module.CloudPurchase.View.Item.CloudPurchaseRewardItem"

function CloudPurchaseRecoderItem:New()
	self = {};
	setmetatable(self, {__index = CloudPurchaseRecoderItem});
	return self
end

function CloudPurchaseRecoderItem:_Init()
	self:_InitReference();
	
	self:UpdateItem(self.data)
end

function CloudPurchaseRecoderItem:_InitReference()
	self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "name");
	self._rewardItem = CloudPurchaseRewardItem:New()
	self._rewardItem:Init(self.transform)
end


function CloudPurchaseRecoderItem:_Dispose()
	
	self._rewardItem:Dispose()
	self._rewardItem = nil
end

function CloudPurchaseRecoderItem:UpdateItem(data)
	self.data = data
	if(data) then
        log(self._rewardItem)
		self._rewardItem:UpdateItem(self.data.reward)
		self._txtName.text = self.data.name
	end
end


return CloudPurchaseRecoderItem 