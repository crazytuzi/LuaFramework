local QUIDialog = import(".QUIDialog")
local QUIDialogSunWarFirstWin = class("QUIDialogSunWarFirstWin", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogSunWarFirstWin:ctor(options)
	local ccbFile = "ccb/Dialog_SunWar_FirstWin.ccbi"
	local callBacks = {}
	QUIDialogSunWarFirstWin.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page.topBar:setAllSound(false)

	self._luckyDraw = options.luckyDraw
	self._userComeBackRatio = options.userComeBackRatio or 1
	self._activityYield = options.activityYield or 1
	if self._userComeBackRatio > 1 then
		self._activityYield = (self._activityYield - 1) + (self._userComeBackRatio - 1) + 1
	end
	local index = 1
	if self._luckyDraw and self._luckyDraw.prizes then
		for _, value in pairs( self._luckyDraw.prizes ) do
			if self._ccbOwner["node_item_"..index] then
				local node = self:_getIcon(value.type, value.id, value.count)
				self._ccbOwner["node_item_"..index]:addChild(node)
				index = index + 1
			end
		end
	end
	self._ccbOwner.tf_text:setString("海神岛中，首次通关都可获得丰厚奖励。魂师大人，请继续前行吧！")

end

--[[
    设置icon
]]
function QUIDialogSunWarFirstWin:_getIcon( type, id, count )
    local node = nil
    node = QUIWidgetItemsBox.new()
    node:setGoodsInfo(id, type, count)
    if self._activityYield and self._activityYield > 1 and (type == ITEM_TYPE.SUNWELL_MONEY or type == "SUNWELL_MONEY") then
    	node:setRateActivityState(true, self._activityYield)
    end
    return node
end

function QUIDialogSunWarFirstWin:viewDidAppear()
	QUIDialogSunWarFirstWin.super.viewDidAppear(self)
end 

function QUIDialogSunWarFirstWin:viewWillDisappear()
	QUIDialogSunWarFirstWin.super.viewWillDisappear(self)
	remote.user:update({luckyDraw = self._luckyDraw})
	if self._luckyDraw.items then remote.items:setItems(self._luckyDraw.items) end
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page.topBar:setAllSound(true)
end 

function QUIDialogSunWarFirstWin:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogSunWarFirstWin:_onTriggerClose()
	app.sound:playSound("common_cancel")
   	self:playEffectOut()
end

function QUIDialogSunWarFirstWin:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogSunWarFirstWin
