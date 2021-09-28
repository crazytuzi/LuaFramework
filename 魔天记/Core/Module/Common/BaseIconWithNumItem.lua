local BaseIconItem = require "Core.Module.Common.BaseIconItem"
local BaseIconWithNumItem = class("BaseIconWithNumItem", BaseIconItem);

function BaseIconWithNumItem:New()
	self = {};
	setmetatable(self, {__index = BaseIconWithNumItem});
	return self
end

function BaseIconWithNumItem:_InitOther()
	self._txtNum = UIUtil.GetChildByName(self.transform, "UILabel", "num");
end

function BaseIconWithNumItem:_DisposeOther()
	
end

function BaseIconWithNumItem:_UpdateOther()
	if(self.data) then
		self._txtNum.text =(self.data.num > 1) and self.data.num or ""		
	end
end

return BaseIconWithNumItem 