-- @Author: zhouxiaoshu
-- @Date:   2019-09-11 12:20:53
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-12-23 14:39:18
local QUIDialog = import(".QUIDialog")
local QUIDialogSotoEntrance = class("QUIDialogSotoEntrance", QUIDialog)
local QUIViewController = import("..QUIViewController")
local QUIWidgetIconAniTips = import("..widgets.QUIWidgetIconAniTips")

--初始化
function QUIDialogSotoEntrance:ctor(options)
	local ccbFile = "Dialog_Soto_entrance.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerRight)},
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerLeft)},
	}
	QUIDialogSotoEntrance.super.ctor(self,ccbFile,callBacks,options)

    CalculateUIBgSize(self._ccbOwner.sp_bg)
    CalculateUIBgSize(self._ccbOwner.node_effect,1280)
    
	--代码
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.setAllUIVisible then page:setAllUIVisible(false) end
    if page.setScalingVisible then page:setScalingVisible(false) end

	self:setInfo()
end

function QUIDialogSotoEntrance:viewDidAppear()
	QUIDialogSotoEntrance.super.viewDidAppear(self)
	self:addBackEvent(false)
end

function QUIDialogSotoEntrance:viewWillDisappear()
	QUIDialogSotoEntrance.super.viewWillDisappear(self)
	self:removeBackEvent()
end

function QUIDialogSotoEntrance:setInfo()
	if remote.arena:getTips(true) then
		local arenaFightTips = QUIWidgetIconAniTips.new()
		arenaFightTips:setInfo(1, 4, "", "down")
		self._ccbOwner.node_fight_tips_left:addChild(arenaFightTips)
	end

	if remote.sotoTeam:checkFightRedTips() then
		local sotoTeamFightTips = QUIWidgetIconAniTips.new()
		sotoTeamFightTips:setInfo(1, 4, "", "down")
		self._ccbOwner.node_fight_tips_right:addChild(sotoTeamFightTips)
	end
end

function QUIDialogSotoEntrance:_onTriggerLeft(event)
	if q.buttonEvent(event, self._ccbOwner.sp_icon_left) == false then return end
    app.sound:playSound("common_small")
	remote.arena:openArena()
end

function QUIDialogSotoEntrance:_onTriggerRight(event)
	if q.buttonEvent(event, self._ccbOwner.sp_icon_right) == false then return end
    app.sound:playSound("common_small")
	remote.sotoTeam:openDialog()
end

return QUIDialogSotoEntrance
