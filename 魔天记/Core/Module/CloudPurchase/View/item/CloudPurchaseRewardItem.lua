local BaseIconWithNumItem = require "Core.Module.Common.BaseIconWithNumItem"
local CloudPurchaseRewardItem = class("CloudPurchaseRewardItem", BaseIconWithNumItem);

function CloudPurchaseRewardItem:New()
	self = {};
	setmetatable(self, {__index = CloudPurchaseRewardItem});
	return self
end 
 
return CloudPurchaseRewardItem 