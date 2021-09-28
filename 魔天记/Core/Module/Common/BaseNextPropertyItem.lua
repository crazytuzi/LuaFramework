require "Core.Module.Common.UIItem"
local BaseNextPropertyItem = class("BaseNextPropertyItem", UIItem);

function BaseNextPropertyItem:New()
	self = {};
	setmetatable(self, {__index = BaseNextPropertyItem});
	return self
end

function BaseNextPropertyItem:_Init()
	local txts = UIUtil.GetChildByName(self.transform, "UILabel", "txtDes");
	self._txtDes = txts
	-- self._txtProperty = UIUtil.GetChildInComponents(txts, "txtProperty")
	self:UpdateItem(self.data)
end


function BaseNextPropertyItem:UpdateItem(data)
	self.data = data
	if(self.data) then
		self._txtDes.text = self.data.property .. self.data.sign
	end
end 

return BaseNextPropertyItem