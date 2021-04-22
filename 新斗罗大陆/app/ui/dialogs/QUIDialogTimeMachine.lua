--
-- Author: Your Name
-- Date: 2014-11-28 15:12:46
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogTimeMachine = class("QUIDialogTimeMachine", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetTimeMachine = import("..widgets.QUIWidgetTimeMachine")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QVIPUtil = import("...utils.QVIPUtil")

local STRENGTH_TEXT = "每周一、三、五、日开启"
local INTELLECT_TEXT = "每周二、四、六、日开启"
QUIDialogTimeMachine.CD_TIMEOUT = "QUIDialogTimeMachine.CD_TIMEOUT"

function QUIDialogTimeMachine:ctor(options)
	local ccbFile = "ccb/Dialog_TimeMachine.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerBootyBay", callback = handler(self, QUIDialogTimeMachine._onTriggerBootyBay)},
		{ccbCallbackName = "onTriggerTavern", callback = handler(self, QUIDialogTimeMachine._onTriggerTavern)},
		{ccbCallbackName = "onTriggerStrengthen", callback = handler(self, QUIDialogTimeMachine._onTriggerStrengthen)},
		{ccbCallbackName = "onTriggerIntellect", callback = handler(self, QUIDialogTimeMachine._onTriggerIntellect)},
	}
	QUIDialogTimeMachine.super.ctor(self, ccbFile, callBacks, options)

	app:getNavigationManager():getController(app.mainUILayer):getTopPage():setManyUIVisible()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setManyUIVisible()
    page:setScalingVisible(true)

	self._initPage = options.initPage
	self._isShowTanNian = options.isShowTanNian or false
	self:init()
end

function QUIDialogTimeMachine:viewDidAppear()
	QUIDialogTimeMachine.super.viewDidAppear(self)
	self:addBackEvent()

	self._userEventProxy = cc.EventProxy.new(remote.user)
    self._userEventProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, function ()
    	self:update()
    end)

	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self._exitFromBattle, self)

    if self._isShowTanNian then
		if app.tip.UNLOCK_TIP_ISTRUE == false then
			app.tip:showUnlockTips(UNLOCK_TUTORIAL_TIPS_TYPE.unlockDwarfCellar)
		else
			app.tip:addUnlockTips(UNLOCK_TUTORIAL_TIPS_TYPE.unlockDwarfCellar)
		end
    end
end

function QUIDialogTimeMachine:viewWillDisappear()
  	QUIDialogTimeMachine.super.viewWillDisappear(self)
	self:removeBackEvent()

    self._userEventProxy:removeAllEventListeners()
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self._exitFromBattle, self)
end

function QUIDialogTimeMachine:init()
	local aList = self:update()

	self._client = QUIWidgetTimeMachine.new({type = 1, availability = self._activityAvailable(1), options = self:getOptions(), cdCallback = function ( ... )
			QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIDialogTimeMachine.CD_TIMEOUT})
			self:update()
		end})
	self._ccbOwner.clientNode:addChild(self._client)

	if not self:getOptions().initPage then self:getOptions().initPage = 1 end
	
	if self._activityAvailable(self:getOptions().initPage) or self:getOptions().isQuickWay then
		self._ccbOwner[self:_convertNumbertoButtonClick(self:getOptions().initPage)]()
	else
		self._ccbOwner[self:_convertNumbertoButtonClick(aList[1])]()
	end
end

function QUIDialogTimeMachine:update()
	local weekday = tonumber(q.date("%w", q.serverTime()-(remote.user.c_systemRefreshTime*3600)))
	local aList, naList, text = {}, {}, ""
	if weekday == 0 then
		aList = {app.unlock:checkLock("UNLOCK_BPPTY_BAY") and 1 or nil, 
					app.unlock:checkLock("UNLOCK_DWARF_CELLAR") and 2 or nil, 
					app.unlock:checkLock("UNLOCK_STRENGTH_TRIAL") and 3 or nil, 
					app.unlock:checkLock("UNLOCK_SAPIENTIAL_TRIAL") and 4 or nil}
	elseif weekday == 1 or weekday == 3 or weekday == 5 then
		aList = {app.unlock:checkLock("UNLOCK_BPPTY_BAY") and 1 or nil, 
					app.unlock:checkLock("UNLOCK_DWARF_CELLAR") and 2 or nil,
					app.unlock:checkLock("UNLOCK_STRENGTH_TRIAL") and 3 or nil,}
		naList = {app.unlock:checkLock("UNLOCK_SAPIENTIAL_TRIAL") and 4 or nil}
		text = "（" .. INTELLECT_TEXT .. "）"
	else
		aList = {app.unlock:checkLock("UNLOCK_BPPTY_BAY") and 1 or nil, 
					app.unlock:checkLock("UNLOCK_DWARF_CELLAR") and 2 or nil,
					app.unlock:checkLock("UNLOCK_SAPIENTIAL_TRIAL") and 4 or nil}
		naList = {app.unlock:checkLock("UNLOCK_STRENGTH_TRIAL") and 3 or nil}
		text = "（" .. STRENGTH_TEXT .. "）"
	end

	self._activityAvailable = function (type)
		for i = 1, #aList do
			if aList[i] ==  type then
				return true
			end
		end

		for i = 1, #naList do
			if naList[i] ==  type then
				return false
			end
		end

		return false
	end

	self:_updateButtons(aList, naList, text)

	return aList
end

function QUIDialogTimeMachine:_updateButtons(aList, naList, text)
	self._ccbOwner.node_btn_bootyBay:setVisible(false)
	self._ccbOwner.node_btn_tavern:setVisible(false)
	self._ccbOwner.node_btn_strengthen:setVisible(false)
	self._ccbOwner.node_btn_intellect:setVisible(false)
	self._ccbOwner.text1:setVisible(false)
	self._ccbOwner.text2:setVisible(false)
	self._ccbOwner.text3:setVisible(false)
	self._ccbOwner.text4:setVisible(false)
	self._ccbOwner.tip1:setVisible(false)
	self._ccbOwner.tip2:setVisible(false)
	self._ccbOwner.tip3:setVisible(false)
	self._ccbOwner.tip4:setVisible(false)

	local index, height = 0, 76
	for i = 1, #aList do
		if aList[i] then
			print("self:_convertNumbertoType(aList[i]) = "..self:_convertNumbertoType(aList[i]))
			self._ccbOwner[self:_convertNumbertoType(aList[i])]:setPositionY(23 -index * height)
			self._ccbOwner[self:_convertNumbertoType(aList[i])]:setVisible(true)
			-- self._ccbOwner["text"..(index + 1)]:setVisible(false)
			-- self._ccbOwner["text"..(index + 1)]:setPositionY(-index * height-19)
			self._ccbOwner["tip"..(index + 1)]:setVisible(self:_freeFightAvailable(aList[i]))
			-- self._ccbOwner["tip"..(index + 1)]:setPositionY(-index * height+30)
			index = index + 1
		end
	end

	for i = 1, #naList do
		if naList[i] then
			self._ccbOwner[self:_convertNumbertoType(naList[i])]:setPositionY(23 -index * height)
			self._ccbOwner[self:_convertNumbertoType(naList[i])]:setVisible(true)
			-- self._ccbOwner["text"..(index + 1)]:setVisible(true)
			-- self._ccbOwner["text"..(index + 1)]:setString(text)
			-- self._ccbOwner["text"..(index + 1)]:setPositionY(-index * height)
			index = index + 1
		end
	end
end

function QUIDialogTimeMachine:_convertNumbertoType(number)
	if number == 1 then
		return "node_btn_bootyBay"
	elseif number == 2 then
		return "node_btn_tavern"
	elseif number == 3 then
		return "node_btn_strengthen"
	else
		return "node_btn_intellect"
	end
end

function QUIDialogTimeMachine:_convertNumbertoButtonClick(number)
	if number == 1 then
		return "onTriggerBootyBay"
	elseif number == 2 then
		return "onTriggerTavern"
	elseif number == 3 then
		return "onTriggerStrengthen"
	else
		return "onTriggerIntellect"
	end
end

function QUIDialogTimeMachine:_freeFightAvailable(type)
	local instance_type = nil
	if type == 1 then
		instance_type = ACTIVITY_DUNGEON_TYPE.TREASURE_BAY
	elseif type == 2 then
		instance_type = ACTIVITY_DUNGEON_TYPE.BLACK_IRON_BAR
	elseif type == 3 then
		instance_type = ACTIVITY_DUNGEON_TYPE.STRENGTH_CHALLENGE
	else
		instance_type = ACTIVITY_DUNGEON_TYPE.WISDOM_CHALLENGE
	end

	local config = remote.activityInstance:getInstanceListById(instance_type)
	local maxCount = remote.activityInstance:getAttackMaxCountByType(config[1].instance_id)
	local attackCount = remote.activityInstance:getAttackCountByType(config[1].instance_id)

	if maxCount > attackCount then
		if QVIPUtil:getActivityNoCD() == true then
			return true
		end
		if app.unlock:checkLock("HUODONGBENXIAO_CD") == true then
			return true
		end
		local cdConfig = QStaticDatabase:sharedDatabase():getConfiguration().DUNGEON_ACTIVITIES_CD.value
		local activityLatest = 0
		for index = 1, 6 do
			local activityCD = remote.instance:dungeonLastPassAt(QUIWidgetTimeMachine._convertTypeToDungeonType(nil, type) .. index)
			if activityCD > activityLatest then
				activityLatest = activityCD 
			end
		end

		return not (activityLatest > 0 and math.floor((q.serverTime()*1000 - activityLatest)/1000) < cdConfig)
	else
		return false
	end
end

function QUIDialogTimeMachine:_onTriggerBootyBay(e)
    if e ~= nil then app.sound:playSound("common_switch") end
	self:_updateButtonStatus("btn_bootyBay")
	self._client:update(1, self._activityAvailable(1), "")
end

function QUIDialogTimeMachine:_onTriggerTavern(e)
    if e ~= nil then app.sound:playSound("common_switch") end
	self:_updateButtonStatus("btn_tavern")
	self._client:update(2, self._activityAvailable(2), "")
end

function QUIDialogTimeMachine:_onTriggerStrengthen(e)
    if e ~= nil then app.sound:playSound("common_switch") end
	self:_updateButtonStatus("btn_strengthen")
	self._client:update(3, self._activityAvailable(3), STRENGTH_TEXT)
end

function QUIDialogTimeMachine:_onTriggerIntellect(e)
    if e ~= nil then app.sound:playSound("common_switch") end
	self:_updateButtonStatus("btn_intellect")	
	self._client:update(4, self._activityAvailable(4), INTELLECT_TEXT)
end

function QUIDialogTimeMachine:_updateButtonStatus(buttonName)
	self._ccbOwner.btn_bootyBay:setHighlighted(buttonName == "btn_bootyBay")
	self._ccbOwner.btn_tavern:setHighlighted(buttonName == "btn_tavern")
	self._ccbOwner.btn_strengthen:setHighlighted(buttonName == "btn_strengthen")
	self._ccbOwner.btn_intellect:setHighlighted(buttonName == "btn_intellect")
end

function QUIDialogTimeMachine:_exitFromBattle()
	print("exit from battle")
	self:update()
	self._client:refresh()
end

-- 对话框退出
function QUIDialogTimeMachine:onTriggerBackHandler(tag, menuItem)
	-- g_timeMachineOption = nil
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

-- 对话框退出
function QUIDialogTimeMachine:onTriggerHomeHandler(tag, menuItem)
	-- g_timeMachineOption = nil
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogTimeMachine