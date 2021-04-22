--[[	
	文件名称：QUIWidgetQlistviewItem.lua
	创建时间：2016-03-10 20:49:28
	作者：nieming
	描述：QUIWidgetQlistviewItem
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetQlistviewItem = class("QUIWidgetQlistviewItem", QUIWidget)

--初始化
function QUIWidgetQlistviewItem:ctor(options)
	local ccbFile = "Widget_QListView_Item.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClick",	callback = handler(self, self._onTriggerClick)},
	}
	QUIWidgetQlistviewItem.super.ctor(self,ccbFile,callBacks,options)

end

function QUIWidgetQlistviewItem:setClickBtnSize(size)
	self._ccbOwner.btn_click:setPreferredSize(size)
end

function QUIWidgetQlistviewItem:setClickBtnPosition(positionX, posiitonY)
	self._ccbOwner.btn_click:setPosition(positionX, posiitonY)
end

function QUIWidgetQlistviewItem:setClickCallBack(callback)
	self._clickCallback = callback
end

function QUIWidgetQlistviewItem:onTouchListView(event)
	if self._itemNode and self._itemNode.onTouchListView then
		self._itemNode:onTouchListView(event)
	end
end

function QUIWidgetQlistviewItem:_onTriggerClick()
	if self._clickCallback then
		self._clickCallback()
	end
end

return QUIWidgetQlistviewItem
