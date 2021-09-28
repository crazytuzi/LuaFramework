require "Core.Module.Common.UIItem"
BasePropertyItem = class("BasePropertyItem", UIItem);

function BasePropertyItem:New()
	self = {};
	setmetatable(self, {__index = BasePropertyItem});
	return self
end

function BasePropertyItem:_Init()
	local txts = UIUtil.GetChildByName(self.transform, "UILabel", "txtDes");
	self._txtDes = txts
	-- self._txtProperty = UIUtil.GetChildInComponents(txts, "txtProperty")
	self:UpdateItem(self.data)
end


function BasePropertyItem:UpdateItem(data)
	self.data = data
	if(data == nil) then return end	 
	 
	local sign = self.data.sign
	 
	if(self.data.key == "exp_per") then
		self._txtDes.text = data.des .. "：+" .. data.property .. sign
	else
		self._txtDes.text = data.des .. "：" .. data.property .. sign
	end
end 