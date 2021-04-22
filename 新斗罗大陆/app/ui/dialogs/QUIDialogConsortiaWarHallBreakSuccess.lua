-- @Author: zhouxiaoshu
-- @Date:   2019-05-09 17:52:45
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-01-21 16:59:29
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogConsortiaWarHallBreakSuccess = class("QUIDialogConsortiaWarHallBreakSuccess", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogConsortiaWarHallBreakSuccess:ctor(options)
	local ccbFile = "ccb/Dialog_UnionWar_success.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogConsortiaWarHallBreakSuccess.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

    self._callback = options.callback

	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)

    self:setInfo(options.info)
end

function QUIDialogConsortiaWarHallBreakSuccess:setInfo(info)
    self._ccbOwner.tf_num1:setString(info.oldFlags or 0)
    self._ccbOwner.tf_num2:setString(info.newFlags or 0)
    
    local width = 100
    local index = 0
    for i, award in pairs(info.awards) do
        local itemBoxs = QUIWidgetItemsBox.new()
		itemBoxs:setGoodsInfo(award.id, award.typeName, award.count)
		itemBoxs:setPromptIsOpen(true)
		itemBoxs:showEffect()
		self._ccbOwner.node_item:addChild( itemBoxs )
		itemBoxs:setPositionX(width*index)
		index = index + 1
    end
	local posX = self._ccbOwner.node_item:getPositionX()
	self._ccbOwner.node_item:setPositionX(posX - width/2)
end

function QUIDialogConsortiaWarHallBreakSuccess:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogConsortiaWarHallBreakSuccess:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogConsortiaWarHallBreakSuccess:viewAnimationOutHandler()
	local callback = self._callback

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogConsortiaWarHallBreakSuccess
