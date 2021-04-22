-- @Author: liaoxianbo
-- @Date:   2020-04-08 14:38:08
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-27 15:14:17
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulTowerEntrance = class("QUIDialogSoulTowerEntrance", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetIconAniTips = import("..widgets.QUIWidgetIconAniTips")

function QUIDialogSoulTowerEntrance:ctor(options)
	local ccbFile = "ccb/Dialog_Soul_tower_choose.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerRight)},
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerLeft)},
    }
    QUIDialogSoulTowerEntrance.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	--代码
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.setAllUIVisible then page:setAllUIVisible(false) end
    if page.setScalingVisible then page:setScalingVisible(false) end
    CalculateUIBgSize(self._ccbOwner.sp_bg)
end

function QUIDialogSoulTowerEntrance:viewDidAppear()
	QUIDialogSoulTowerEntrance.super.viewDidAppear(self)
	self:addBackEvent(false)

	self:setInfo()
	self:setRoundTime()
end

function QUIDialogSoulTowerEntrance:viewWillDisappear()
  	QUIDialogSoulTowerEntrance.super.viewWillDisappear(self)

	self:removeBackEvent()

	if self._timeScheduler then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end   	
end

function QUIDialogSoulTowerEntrance:setInfo()
	if remote.blackrock:checkRedTip() then
		local blackrockFightTips = QUIWidgetIconAniTips.new()
		blackrockFightTips:setInfo(1, 4, "", "down")
		self._ccbOwner.node_fight_tips_left:addChild(blackrockFightTips)
	end

 --    local soulTowerInfo = remote.soultower:getMySoulTowerInfo()
 --    local wave = soulTowerInfo and soulTowerInfo.wave or 0
 --    print("升灵台----wave----",wave)
 --    QPrintTable(soulTowerInfo)
	-- if wave <= 0 then
	-- 	local soultowerFightTips = QUIWidgetIconAniTips.new()
	-- 	soultowerFightTips:setInfo(1, 4, "", "down")
	-- 	self._ccbOwner.node_fight_tips_right:addChild(soultowerFightTips)
	-- end
	local myRank = remote.soultower:getMySeverRank()
	local awardInfo = remote.soultower:getSoulTowerRoundEndAward()
	if q.isEmpty(awardInfo) == false or myRank <= 0 then
		local soultowerFightTips = QUIWidgetIconAniTips.new()
		soultowerFightTips:setInfo(1, 4, "", "down")
		self._ccbOwner.node_fight_tips_right:addChild(soultowerFightTips)		
	end
end

function QUIDialogSoulTowerEntrance:setRoundTime()
	if self._timeScheduler then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end
	local rundInfo = remote.soultower:getSoulTowerMyRoundInfo() or {}
	local endTime = rundInfo.endAt or 0
	local billTime = endTime + HOUR*1000

	local timeFunc
	timeFunc = function ( )
		local lastTime = endTime/1000 - q.serverTime()
		local billLastTime = billTime/1000 - q.serverTime()
		if self:safeCheck() then
			if lastTime > 0 then
				local timeStr = q.timeToDayHourMinute(lastTime)
				self._ccbOwner.tf_endtime:setString("剩余："..timeStr)
			elseif billLastTime > 0 then
				remote.soultower:initData()
				local timeStr = q.timeToDayHourMinute(billLastTime)
				self._ccbOwner.tf_endtime:setString("结算剩余："..timeStr)
			else 
				if self._timeScheduler then
					scheduler.unscheduleGlobal(self._timeScheduler)
					self._timeScheduler = nil
				end
				remote.soultower:initData()
				self._ccbOwner.tf_endtime:setString("新一轮已开启")
			end
		end
	end

	self._timeScheduler = scheduler.scheduleGlobal(timeFunc, 1)
	timeFunc()
end

function QUIDialogSoulTowerEntrance:_onTriggerLeft(event)
	if q.buttonEvent(event, self._ccbOwner.sp_icon_left) == false then return end
    app.sound:playSound("common_small")

	remote.blackrock:openDialog()
end

function QUIDialogSoulTowerEntrance:_onTriggerRight(event)
	if q.buttonEvent(event, self._ccbOwner.sp_icon_right) == false then return end
    app.sound:playSound("common_small")

	remote.soultower:openDialog()
end

return QUIDialogSoulTowerEntrance
