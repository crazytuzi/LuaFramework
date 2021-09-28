local BaseNextPropertyItem = require "Core.Module.Common.BaseNextPropertyItem"

local PetNextAttrItem = class("PetNextAttrItem", BaseNextPropertyItem);
local greenCode = "[" ..ColorDataManager.ConventToColorCode(ColorDataManager.Get_green()) .. "]"
function PetNextAttrItem:New()
	self = {};
	setmetatable(self, {__index = PetNextAttrItem});
	return self
end



function PetNextAttrItem:UpdateItem(data)
	self.data = data
	if(self.data) then
		
		self._txtDes.text =	self.data.des .. "：" .. greenCode .. self.data.property .. self.data.sign
	end
end

return PetNextAttrItem
