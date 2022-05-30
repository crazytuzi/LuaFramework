local ActivityItem = class("ActivityItem", function()
	--return cc.Node:create()
	return CCTableViewCell:new()
end)


function ActivityItem:getContentSize()
	return cc.size(108, 98)
end


function ActivityItem:ctor()
	self:setContentSize(self:getContentSize())
end


function ActivityItem:getId()
	return self._id
end


function ActivityItem:create(param)
	local _viewSize = param.viewSize
	local _itemData  = param.itemData
	self._id = _itemData.huodong
	
	local high_light_frame = "ui/new_btn/common_highlight_frame.png"
	
	self._heroIcon = display.newSprite("#" .. _itemData.icon .. ".png")
	self:addChild(self._heroIcon)
	self._heroIcon:setPosition(self._heroIcon:getContentSize().width / 2, _viewSize.height / 2)
	
	self._selectedFrame = display.newSprite(high_light_frame)
	self._selectedFrame:setPosition(self._heroIcon:getContentSize().width/2, self._heroIcon:getContentSize().height/2)
	self._heroIcon:addChild(self._selectedFrame)
	self._selectedFrame:setVisible(false)
	
	return self
end


function ActivityItem:refresh(itemData, selected)
	if itemData ~= nil then
		self._id = itemData.huodong
		self._heroIcon:setDisplayFrame(display.newSprite("#" .. itemData.icon .. ".png"):getDisplayFrame())
	end
	local selected = selected or false
	if selected == true then
		self:setSelected(true)
	else
		self:setSelected(false)
	end
end


function ActivityItem:setSelected(bSelected)
	-- dump(self._id)
	self._selectedFrame:setVisible(bSelected)
end

return ActivityItem