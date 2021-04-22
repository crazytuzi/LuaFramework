--
-- Author: xurui
-- Date: 2016-05-19 19:37:18
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMyInformation = class("QUIWidgetMyInformation", QUIWidget)

local QUIViewController = import("..QUIViewController")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QVIPUtil = import("...utils.QVIPUtil")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIDialogUnionAnnouncement = import("..dialogs.QUIDialogUnionAnnouncement")

local currentType = {"token", "money", "soulMoney", "arenaMoney", "thunderMoney", "intrusion_money", "sunwellMoney", "towerMoney"}

function QUIWidgetMyInformation:ctor(options)
	local ccbFile = "ccb/Widget_Rongyao_wanjia.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerChangeName", callback = handler(self, self._onTriggerChangeName)},
		{ccbCallbackName = "onTriggerClickHeroHead", callback = handler(self, self._onTriggerClickHeroHead)},
		{ccbCallbackName = "onTriggerPersonalSetting", callback = handler(self, self._onTriggerPersonalSetting)},
		{ccbCallbackName = "onTriggerWord", callback = handler(self, self._onTriggerWord)},
		{ccbCallbackName = "onTriggerClickCard", callback = handler(self, self._onTriggerClickCard)},
		{ccbCallbackName = "onTriggerXiaoNaNa", callback = handler(self, self._onTriggerXiaoNaNa)},
	}
	QUIWidgetMyInformation.super.ctor(self, ccbFile, callBacks, options)

	self._currencyNum = {}
	self._currencyIcon = {}
	self._timeScheduler = {}

	self._currentInvationNum = remote.user.intrusion_token or 0

	self._ccbOwner.node_month_card:setVisible(ENABLE_CHARGE())
end

function QUIWidgetMyInformation:onEnter()
	-- self._userEventProxy = cc.EventProxy.new(remote.user)
	-- self._userEventProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self.setUserInfo))

end

function QUIWidgetMyInformation:onExit()
	if self._userEventProxy ~= nil then
		self._userEventProxy:removeAllEventListeners()
		self._userEventProxy = nil
	end

	for i = 1, 8 do
		self:cleanTimeScheduler(i)
	end
end

function QUIWidgetMyInformation:cleanTimeScheduler(index)
	if self._timeScheduler[index] ~= nil then
		scheduler.unscheduleGlobal(self._timeScheduler[index])
		self._timeScheduler[index] = nil
	end
end

function QUIWidgetMyInformation:setUserInfo()
	self:setAvatar()

	self._ccbOwner.tf_team_level:setString(remote.user.level or "-1")
	self._ccbOwner.tf_name:setString(remote.user.nickname or "")

	local nextExp = QStaticDatabase:sharedDatabase():getExperienceByTeamLevel(remote.user.level)
	self._ccbOwner.tf_exp:setString(string.format("%d/%d", remote.user.exp or -1, nextExp or -1))
	local scale = remote.user.exp/nextExp
	if scale > 1 then scale = 1 end
	self._ccbOwner.exp_bar:setScaleX(scale)

    -- month card
    local nowTime = q.serverTime()
    if remote.recharge.monthCard1EndTime/1000 < nowTime then
		makeNodeFromNormalToGray(self._ccbOwner.month_card)
    end
    if remote.recharge.monthCard2EndTime/1000 < nowTime then
		makeNodeFromNormalToGray(self._ccbOwner.rich_month_card)
    end

    local battleForce = remote.herosUtil:getMostHeroBattleForce()
	self._ccbOwner.tf_battle_force:setString(battleForce or "")

	self._ccbOwner.tf_limit_level:setString(remote.user.level)
	self._ccbOwner.tf_vip:setString("VIP"..(QVIPUtil:getVIPLevel(remote.user.totalRechargeToken) or -1))

	local title = remote.user.title or 0
	if title == 0 then
		local info = remote.headProp:getTitleInfoBySoulTrial(remote.user.soulTrial)
		if info then
			title = info.id or 0
		end
	end
	local titleInfo = QStaticDatabase:sharedDatabase():getHeadInfoById(title) or {}
	self._ccbOwner.tf_title:setString(titleInfo.desc or "无")

	local consortiaName = remote.user.userConsortia ~= nil and remote.user.userConsortia.consortiaName or "无"
	self._ccbOwner.tf_union_name:setString(consortiaName or "无")

	self._declaration = remote.user.declaration
	if remote.user.declaration == nil or remote.user.declaration == "" then
		self._declaration = "这家伙很懒， 什么也没有留下"
	end
	self._ccbOwner.tf_word:setString(self._declaration)

	self:_setCountdownInfo()
end

function QUIWidgetMyInformation:setAvatar()
	-- build objects for avatar
	if self._avatar == nil then
		self._avatar = QUIWidgetAvatar.new(remote.user.avatar)
		self._ccbOwner.node_head:addChild(self._avatar)
	end
	self._avatar:setInfo(remote.user.avatar)
	self._avatar:setSoulTrial(remote.user.soulTrial)
	self._avatar:setSilvesArenaPeak(remote.user.championCount)
end

function QUIWidgetMyInformation:_setCountdownInfo()
	-- set energy info
	local maxEnergy = QStaticDatabase:sharedDatabase():getConfig().max_energy
	local currentEnergy = remote.user.energy or 0
	if currentEnergy >= maxEnergy then
		self._ccbOwner.tf_energy_time:setString("体力已满")
		self._ccbOwner.tf_energy_time:setColor(GAME_COLOR_LIGHT.property)

		self:cleanTimeScheduler(1)
	else
		local gapTime = global.config.energy_refresh_interval
		local nextRefreshTime = 0
		if remote.user._timeProps and remote.user._timeProps["energy"] then
			nextRefreshTime = (remote.user._timeProps["energy"].stepTime or 0) - (remote.user._timeProps["energy"].startTime or 0)
		end
		local allFullTime = nextRefreshTime + (maxEnergy - currentEnergy - 1) * gapTime
		self:_setRestoreScheduler(1, self._ccbOwner.tf_energy_time, allFullTime)
	end

	-- set skill point info 
	local maxSkillPointNum = QVIPUtil:getSkillPointCount()
	if app.unlock:getUnlockSkill() then
	    local currentSkillPoint, lastTime = remote.herosUtil:getSkillPointAndTime()
		if currentSkillPoint >= maxSkillPointNum then
			self._ccbOwner.tf_skill_point_time:setString("魂技点已满")
			self._ccbOwner.tf_skill_point_time:setColor(GAME_COLOR_LIGHT.property)

			self:cleanTimeScheduler(2)
		else
			local gapTime = QStaticDatabase:sharedDatabase():getConfiguration()["SP_RECOVE_SPEED"].value 
			if remote.activity:checkMonthCardActive(2) then
				gapTime = gapTime/2
			end
			local nextRefreshTime = lastTime
			local allFullTime = nextRefreshTime + (maxSkillPointNum - currentSkillPoint - 1) * gapTime
			self:_setRestoreScheduler(2, self._ccbOwner.tf_skill_point_time, allFullTime)
		end
	else
		self._ccbOwner.tf_skill_point_time:setString("魂技点已满")
		self._ccbOwner.tf_skill_point_time:setColor(GAME_COLOR_LIGHT.property)
 	end 
end  

function QUIWidgetMyInformation:_setRestoreScheduler(index, tf, nextTime, currentNum)
	if self._timeScheduler[index] ~= nil then
		scheduler.unscheduleGlobal(self._timeScheduler[index])
		self._timeScheduler[index] = nil
	end

	local refreshTime = nextTime
	local schedulerFunc = nil
	schedulerFunc = function()
		if refreshTime >= 1 then
			refreshTime = refreshTime - 1

			tf:setString(q.timeToHourMinuteSecond(refreshTime))
		else
			if index == 5 then
				self._currentInvationNum = self._currentInvationNum + 1
			elseif index == 7 then
				self._currentTowerNum = self._currentTowerNum + 1
			end
			self:_setCountdownInfo()
		end
	end

	tf:setString(q.timeToHourMinuteSecond(refreshTime))
	self._timeScheduler[index] = scheduler.scheduleGlobal(schedulerFunc, 1)
end

function QUIWidgetMyInformation:_onTriggerChangeName(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_changName) == false then return end
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogChangeName", 
		options = {nickName = remote.user.nickname, nameChangedCallBack = function(newName)
			self._ccbOwner.tf_name:setString(newName)
		end}}, {isPopCurrentDialog = false})
end

function QUIWidgetMyInformation:_onTriggerClickHeroHead()
	-- app.sound:playSound("common_small")
	-- self._chooseHeadDialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogChooseHead"})
	app.funny:trigger()
end

function QUIWidgetMyInformation:_onTriggerPersonalSetting(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_personal_setting) == false then return end
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPersonalSetting"})
end

function QUIWidgetMyInformation:_onTriggerWord(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_word) == false then return end
	app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogUnionAnnouncement", 
        options = {type = QUIDialogUnionAnnouncement.TYPE_ARENA_WORD, word = self._declaration, confirmCallback = function (word)
        	if #word > 0 then
            	remote.arena:arenaSetDeclarationRequest(word, function (data)
            		self._declaration = data.declaration
            		remote.user:update({declaration = self._declaration})
					self._ccbOwner.tf_word:setString(self._declaration)
					app.tip:floatTip("恭喜您, 成功修改宣言")
            	end)
            else
				app.tip:floatTip("请输入内容！")
            end
        end}}, {isPopCurrentDialog = false})
end

function QUIWidgetMyInformation:_onTriggerClickCard()
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityPanel", 
		options = {curActivityID = "a_yueka"}})
end

function QUIWidgetMyInformation:_onTriggerXiaoNaNa()
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogXiaoNaNa"})
end

return QUIWidgetMyInformation