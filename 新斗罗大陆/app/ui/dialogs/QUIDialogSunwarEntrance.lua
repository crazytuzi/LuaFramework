-- @Author: xurui
-- @Date:   2019-12-26 15:35:19
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-12-26 16:01:51
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSunwarEntrance = class("QUIDialogSunwarEntrance", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetIconAniTips = import("..widgets.QUIWidgetIconAniTips")

function QUIDialogSunwarEntrance:ctor(options)
	local ccbFile = "ccb/Dialog_sunwar_choose.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerRight)},
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerLeft)},
    }
    QUIDialogSunwarEntrance.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	--代码
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.setAllUIVisible then page:setAllUIVisible(false) end
    if page.setScalingVisible then page:setScalingVisible(false) end
    CalculateUIBgSize(self._ccbOwner.sp_bg)

end

function QUIDialogSunwarEntrance:viewDidAppear()
	QUIDialogSunwarEntrance.super.viewDidAppear(self)
	self:addBackEvent(false)

	self:setInfo()
end

function QUIDialogSunwarEntrance:viewWillDisappear()
  	QUIDialogSunwarEntrance.super.viewWillDisappear(self)
	self:removeBackEvent()
end

function QUIDialogSunwarEntrance:setInfo()
	if remote.sunWar:checkSunWarCanRevive() then
		local sunwarFightTips = QUIWidgetIconAniTips.new()
		sunwarFightTips:setInfo(1, 3, "", "down")
		self._ccbOwner.node_fight_tips_left:addChild(sunwarFightTips)
	end

	if remote.totemChallenge:checkTips() then
		local totemChallengeFightTips = QUIWidgetIconAniTips.new()
		totemChallengeFightTips:setInfo(1, 4, "", "down")
		self._ccbOwner.node_fight_tips_right:addChild(totemChallengeFightTips)
	end
end

function QUIDialogSunwarEntrance:_onTriggerLeft(event)
	if q.buttonEvent(event, self._ccbOwner.sp_icon_left) == false then return end
    app.sound:playSound("common_small")

	remote.sunWar:openDialog()
end

function QUIDialogSunwarEntrance:_onTriggerRight(event)
	if q.buttonEvent(event, self._ccbOwner.sp_icon_right) == false then return end
    app.sound:playSound("common_small")

	remote.totemChallenge:openDialog()
end

return QUIDialogSunwarEntrance
