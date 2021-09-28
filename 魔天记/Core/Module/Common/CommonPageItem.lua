require "Core.Module.Common.UIItem"
CommonPageItem = class("CommonPageItem", UIItem);

function CommonPageItem:New()
	self = {};
	setmetatable(self, {__index = CommonPageItem});
	return self
end

function CommonPageItem:_Init()
	self._toggle = UIUtil.GetComponent(self.transform, "UIToggle")
	self._toggle:Set(false, false)
end


function CommonPageItem:UpdateItem(data)
	
end

function CommonPageItem:SetToggle(enable)
	self._toggle.value = enable
end

function CommonPageItem:_Dispose()
	self._toggle = nil
end
