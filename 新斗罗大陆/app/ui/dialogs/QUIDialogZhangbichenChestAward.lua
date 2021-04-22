--
-- Kumo.Wang
-- zhangbichen主题曲活动——假宝箱预览界面
--

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogZhangbichenChestAward = class("QUIDialogZhangbichenChestAward", QUIDialog)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogZhangbichenChestAward:ctor(options) 
 	local ccbFile = "ccb/Dialog_Zhangbichen_ChestAward.ccbi"
	local callBacks = {
	    {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogZhangbichenChestAward.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true

	self._ccbOwner.frame_tf_title:setString("宝箱预览")
	q.setButtonEnableShadow(self._ccbOwner.frame_btn_close)

	self._ccbOwner.node_goods:removeAllChildren()
	local info = options.info
	local tbl = string.split(info.rewards, "^")
	if tbl and #tbl > 0 then
		local itemId = tonumber(tbl[1])
		local itemCount = tonumber(tbl[2])
		local itemType = ITEM_TYPE.ITEM
		if not itemId then
			itemType = tbl[1]
		end
		local box = QUIWidgetItemsBox.new()
		box:setGoodsInfo(itemId, itemType, itemCount)
		box:setPromptIsOpen(true)
		self._ccbOwner.node_goods:addChild(box)
	end
end

function QUIDialogZhangbichenChestAward:viewAnimationOutHandler()
	self:popSelf()
end

function QUIDialogZhangbichenChestAward:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogZhangbichenChestAward:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
	if e then
    	app.sound:playSound("common_small")
    end
	self:playEffectOut()
end

return QUIDialogZhangbichenChestAward