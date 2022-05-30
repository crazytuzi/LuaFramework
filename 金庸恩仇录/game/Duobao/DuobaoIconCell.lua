
local DuobaoIconCell = class("DuobaoIconCell", function()
	display.addSpriteFramesWithFile("ui/ui_icon_frame.plist", "ui/ui_icon_frame.png")
	return CCTableViewCell:new()
end)

function DuobaoIconCell:getContentSize()
	return cc.size(105, 105)
end

function DuobaoIconCell:updateItem(param)
	self._id = param.id
	ResMgr.refreshIcon({
	itemBg = self._itemIcon,
	id = self._id,
	resType = ResMgr.getResType(self._type),
	itemType = self._type
	})
	self._selectedFrame:setVisible(param.selectd)
end

function DuobaoIconCell:create(param)
	self._id = param.id
	self._type = param.type
	local viewSize = param.viewSize
	self._itemIcon = ResMgr.getIconSprite({
	id = self._id,
	resType = ResMgr.getResType(self._type)
	})
	self:addChild(self._itemIcon)
	self._itemIcon:setPosition(self._itemIcon:getContentSize().width / 2, viewSize.height / 2)
	local high_light_frame = "ui/new_btn/common_highlight_frame.png"
	self._selectedFrame = display.newSprite(high_light_frame)
	self._selectedFrame:setPosition(self._itemIcon:getContentSize().width / 2, self._itemIcon:getContentSize().height / 2)
	self._itemIcon:addChild(self._selectedFrame)
	self:selected(false)
	return self
end

function DuobaoIconCell:refresh(param)
	self:updateItem(param)
end

function DuobaoIconCell:selected(bSelected)
	self._selectedFrame:setVisible(bSelected)
end

return DuobaoIconCell