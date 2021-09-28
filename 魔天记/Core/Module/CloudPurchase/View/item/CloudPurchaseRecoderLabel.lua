require "Core.Module.Common.UIItem"


local CloudPurchaseRecoderLabel = class("CloudPurchaseRecoderLabel", UIItem);


function CloudPurchaseRecoderLabel:New()
	self = {};
	setmetatable(self, {__index = CloudPurchaseRecoderLabel});
	return self
end

function CloudPurchaseRecoderLabel:_Init()
	self:_InitReference();
	
	self:UpdateItem(self.data)
end

function CloudPurchaseRecoderLabel:_InitReference()
	self._txtDes = UIUtil.GetChildByName(self.transform, "UILabel", "des");	
end


function CloudPurchaseRecoderLabel:_Dispose()
	
	
end

function CloudPurchaseRecoderLabel:UpdateItem(data)
	self.data = data
	if(data) then
		self._txtDes.text = self.data
	end
end


return CloudPurchaseRecoderLabel 