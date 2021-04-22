--
-- Author: Your Name
-- Date: 2014-11-28 15:12:46
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogGoldBattle = class("QUIDialogGoldBattle", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

QUIDialogGoldBattle.BOOTY_BAY = ACTIVITY_DUNGEON_TYPE.STRENGTH_CHALLENGE
QUIDialogGoldBattle.GOLD_TEST = ACTIVITY_DUNGEON_TYPE.WISDOM_CHALLENGE
QUIDialogGoldBattle.EVERY_SECOND = 1
QUIDialogGoldBattle.CD_ERRORTEXT = "冷却时间内无法挑战"

function QUIDialogGoldBattle:ctor(options)
	local ccbFile = "ccb/Dialog_GoldBattle.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClickFristHandler", 				callback = handler(self, QUIDialogGoldBattle._onTriggerClickFristHandler)},
		{ccbCallbackName = "onTriggerClickSecondHandler", 				callback = handler(self, QUIDialogGoldBattle._onTriggerClickSecondHandler)},

	}
	QUIDialogGoldBattle.super.ctor(self,ccbFile,callBacks,options)
	app:getNavigationManager():getController(app.mainUILayer):getTopPage():setManyUIVisible()

	self:initPage()
	self._activity1CD = 0
	self._activity2CD = 0 
	self._maxCount = 5

	local config = remote.activityInstance:getInstanceListById(QUIDialogGoldBattle.BOOTY_BAY)
	self.bootyBayLeftCount = config[1].attack_num - remote.activityInstance:getAttackCountByType(config[1].instance_id)
	config = remote.activityInstance:getInstanceListById(QUIDialogGoldBattle.GOLD_TEST)
	self.dwarfLeftCount = config[1].attack_num - remote.activityInstance:getAttackCountByType(config[1].instance_id)
end

function QUIDialogGoldBattle:viewDidAppear()
	QUIDialogGoldBattle.super.viewDidAppear(self)
	self:addBackEvent()
	self:showCD()

	if self._activity1CD > 0 or self._activity2CD > 0 then
    	self._everySecond = scheduler.scheduleGlobal(handler(self, QUIDialogGoldBattle._onSecond), QUIDialogGoldBattle.EVERY_SECOND)
    end

	self._userEventProxy = cc.EventProxy.new(remote.user)
    self._userEventProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self._userUpdateHandler))
end

function QUIDialogGoldBattle:viewWillDisappear()
  	QUIDialogGoldBattle.super.viewWillDisappear(self)
	self:removeBackEvent()

  	if self._everySecond ~= nil then
  		scheduler.unscheduleGlobal(self._everySecond)
  	end
    self._userEventProxy:removeAllEventListeners()
end

function QUIDialogGoldBattle:initPage()
	self:setInfoByinstanceId(QUIDialogGoldBattle.BOOTY_BAY, 1)
	self:setInfoByinstanceId(QUIDialogGoldBattle.GOLD_TEST, 2)
	self:checkStateByinstanceId(QUIDialogGoldBattle.BOOTY_BAY, 1)
	self:checkStateByinstanceId(QUIDialogGoldBattle.GOLD_TEST, 2)

	local config = QStaticDatabase:sharedDatabase():getConfiguration()
	self._cdConfig = config.DUNGEON_ACTIVITIES_CD.value
end

function QUIDialogGoldBattle:_userUpdateHandler()
	self._attackCount = remote.activityInstance:getAttackCountByType(ACTIVITY_DUNGEON_TYPE.STRENGTH_CHALLENGE)
	if self._attackCount >=  self._maxCount then
		self._ccbOwner.tf_count:setString("")
		self._ccbOwner.tf_count_tips:setString("今日挑战次数已用完")
		self._ccbOwner.tf_count_tips:setColor(UNITY_COLOR_LIGHT.red)
	else
		self._ccbOwner.tf_count:setString((self._maxCount - self._attackCount).."/"..self._maxCount)
		self._ccbOwner.tf_count_tips:setString("今日剩余挑战次数：")
		self._ccbOwner.tf_count_tips:setColor(UNITY_COLOR.yellow)
	end
end

-- @qinyuanji
-- Show CD time if there is for any activities
function QUIDialogGoldBattle:showCD()
	self:_userUpdateHandler()
	-- Activity1
	local activity1Latest = 0
	for index = 1, 6 do
		local activity1CD = remote.instance:dungeonLastPassAt("strength_test_" .. tostring(index))
		if activity1CD > activity1Latest then
			activity1Latest = activity1CD
		end
	end

	if activity1Latest > 0 and math.floor((q.serverTime()*1000 - activity1Latest)/1000) < self._cdConfig and self.bootyBayLeftCount > 0 then
		self._activity1CD = self._cdConfig - math.floor((q.serverTime()*1000 - activity1Latest)/1000)
		self._ccbOwner["activity1_time"]:setString(q.timeToHourMinuteSecond(self._activity1CD) .. "后")
	else
		self._ccbOwner["activity1"]:setVisible(false)
	end

	-- Activity2
	local activity2Latest = 0
	for index = 1, 6 do
		local activity2CD = remote.instance:dungeonLastPassAt("wisdom_test_" .. tostring(index))
		if activity2CD > activity2Latest then
			activity2Latest = activity2CD
		end
	end

	if activity2Latest > 0 and math.floor((q.serverTime()*1000 - activity2Latest)/1000) < self._cdConfig and self.dwarfLeftCount > 0 then
		self._activity2CD = self._cdConfig - math.floor((q.serverTime()*1000 - activity2Latest)/1000)
		self._ccbOwner["activity2_time"]:setString(q.timeToHourMinuteSecond(self._activity2CD) .. "后")
	else
		self._ccbOwner["activity2"]:setVisible(false)
	end
end

function QUIDialogGoldBattle:_onSecond(dt)
	self._activity1CD = self._activity1CD - 1
	self._ccbOwner["activity1_time"]:setString(q.timeToHourMinuteSecond(self._activity1CD) .. "后")
		
	self._activity2CD = self._activity2CD - 1
	self._ccbOwner["activity2_time"]:setString(q.timeToHourMinuteSecond(self._activity2CD) .. "后")

	if self._activity1CD <= 0 then
		self._ccbOwner["activity1"]:setVisible(false)
	end
	if self._activity2CD <= 0 then
		self._ccbOwner["activity2"]:setVisible(false)
	end	
end

-- 设置界面中的信息
function QUIDialogGoldBattle:setInfoByinstanceId(instanceId, index)
	local list = remote.activityInstance:getInstanceListById(instanceId)
	if #list > 0 then
		self._ccbOwner["tf_name_"..index]:setString(list[1].instance_name)
		self._ccbOwner["tf_name_disable_"..index]:setString(list[1].instance_name)
	end
end

--设置界面中的按钮是否可点
function QUIDialogGoldBattle:checkStateByinstanceId(instanceId, index)
	if remote.activityInstance:checkIsOpenForInstanceId(instanceId) == true or true then --现在全开
		self._ccbOwner["node_title_disable_"..index]:setVisible(false)
		self._ccbOwner["node_title_"..index]:setVisible(true)
		self._ccbOwner["bj"..index]:setHighlighted(false)
		self._ccbOwner["bj"..index]:setEnabled(true)
		self._ccbOwner["btn"..index]:setVisible(false)
	else
		self._ccbOwner["node_title_disable_"..index]:setVisible(true)
		self._ccbOwner["node_title_"..index]:setVisible(false)
		self._ccbOwner["bj"..index]:setHighlighted(true)
		self._ccbOwner["bj"..index]:setEnabled(false)
		self._ccbOwner["btn"..index]:setVisible(true)
	end
end

-- 对话框退出
function QUIDialogGoldBattle:onTriggerBackHandler(tag, menuItem)
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

-- 对话框退出
function QUIDialogGoldBattle:onTriggerHomeHandler(tag, menuItem)
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

-- 进入第一个副本
function QUIDialogGoldBattle:_onTriggerClickFristHandler(tag, menuItem)
	if self._attackCount >= self._maxCount then
    	app.tip:floatTip("今日次数已用完")
		return
	end
	if true or remote.activityInstance:checkIsOpenForInstanceId(QUIDialogGoldBattle.BOOTY_BAY) == true then
		if self._activity1CD > 0 then
			app.tip:floatTip(QUIDialogGoldBattle.CD_ERRORTEXT)
			return 
		end

		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogActivityInstance",
			options = {instanceId = QUIDialogGoldBattle.BOOTY_BAY}})
	else
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogActivityTips",
			options = {instanceId = QUIDialogGoldBattle.BOOTY_BAY}})
	end
end

-- 进入第二个副本
function QUIDialogGoldBattle:_onTriggerClickSecondHandler(tag, menuItem)
	if self._attackCount >= self._maxCount then
    	app.tip:floatTip("今日次数已用完")
		return
	end
	if true or remote.activityInstance:checkIsOpenForInstanceId(QUIDialogGoldBattle.GOLD_TEST) == true then
		if self._activity2CD > 0 then
			app.tip:floatTip(QUIDialogGoldBattle.CD_ERRORTEXT)
			return
		end

		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogActivityInstance",
			options = {instanceId = QUIDialogGoldBattle.GOLD_TEST}})
	else
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogActivityTips",
			options = {instanceId = QUIDialogGoldBattle.GOLD_TEST}})
	end
end

function QUIDialogGoldBattle:_tipsTouchHandler()
	self._ccbOwner.node_tips:setVisible(false)
end

return QUIDialogGoldBattle