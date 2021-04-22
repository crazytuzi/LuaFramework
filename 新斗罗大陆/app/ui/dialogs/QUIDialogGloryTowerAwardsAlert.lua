-- @Author: xurui
-- @Date:   2019-03-01 18:16:36
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-03-12 15:32:48
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogGloryTowerAwardsAlert = class("QUIDialogGloryTowerAwardsAlert", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetFloorIcon = import("..widgets.QUIWidgetFloorIcon")

function QUIDialogGloryTowerAwardsAlert:ctor(options)
	local ccbFile = "ccb/Dialog_glory_alert.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogGloryTowerAwardsAlert.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
	    self._lastFloor = options.lastFloor or 1
	    self._floor = options.floor or 1
	    self._awards = options.awards
    end

    self._ccbOwner.tf_title:setString("恭喜您获得升段奖励")
end

function QUIDialogGloryTowerAwardsAlert:viewDidAppear()
	QUIDialogGloryTowerAwardsAlert.super.viewDidAppear(self)

	self:setInfo()
end

function QUIDialogGloryTowerAwardsAlert:viewWillDisappear()
  	QUIDialogGloryTowerAwardsAlert.super.viewWillDisappear(self)
end

function QUIDialogGloryTowerAwardsAlert:setInfo()
	--awards
	local itemType = "token"
	local count = 0
	for _, value in pairs(self._awards) do
		count = count + value.count
	end
	local itemBox = QUIWidgetItemsBox.new()
	itemBox:setGoodsInfo(nil, itemType, count)
	itemBox:setPromptIsOpen(true)
	self._ccbOwner.node_contain:addChild(itemBox)

	self:setGloryIcon()
end

function QUIDialogGloryTowerAwardsAlert:setGloryIcon()
    local oldFloor = QUIWidgetFloorIcon.new({floor = self._lastFloor, isLarge = false, iconType = "tower"})
    oldFloor:setScale(1.2)
    self._ccbOwner.tower_lv_old:removeAllChildren()
    self._ccbOwner.tower_lv_old:addChild(oldFloor)

    local newFloor = QUIWidgetFloorIcon.new({floor = self._floor, isLarge = false, iconType = "tower"})
    newFloor:setScale(1.2)
    self._ccbOwner.tower_lv_new:removeAllChildren()
    self._ccbOwner.tower_lv_new:addChild(newFloor)
end

function QUIDialogGloryTowerAwardsAlert:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogGloryTowerAwardsAlert:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogGloryTowerAwardsAlert:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogGloryTowerAwardsAlert
