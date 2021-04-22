-- @Author: xurui
-- @Date:   2018-10-10 14:32:25
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-03-04 22:24:31
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMetalCityQuickChangeTeam = class("QUIDialogMetalCityQuickChangeTeam", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetMetalCityQuickChangeTeam = import("..widgets.QUIWidgetMetalCityQuickChangeTeam")

local TEAM_INDEX_MOUNT = 9909
QUIDialogMetalCityQuickChangeTeam.GODARM_SAME_FULL = "同类型神器只能同时上两个"
QUIDialogMetalCityQuickChangeTeam.MOUNT_NOT_MATCH_HERO = "该位置没有魂师可以装备暗器"

function QUIDialogMetalCityQuickChangeTeam:ctor(options)
	local ccbFile = "ccb/Dialog_TeamArena_yijian.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogMetalCityQuickChangeTeam.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._team1 = options.teams1
    	self._team2 = options.teams2
    	self._subHeros1 = options.subHeros1
    	self._subHeros2 = options.subHeros2
    	self._soulSpirit1 = options.soulSpirit1
    	self._soulSpirit2 = options.soulSpirit2
    	self._godarmList1 = options.godarmList1
    	self._godarmList2 = options.godarmList2
    	self._callBack = options.callBack
    	self._fighterInfo = options.fighterInfo
    	self._isStromArena = options.isStromArena
    	self._isTotemChallenge = options.isTotemChallenge
    	self._isMockBattle = options.isMockBattle or false
    	self._isDefence = options.isDefence
    	self._isPVP = options.isPVP

    	self._mountList1 = options.mountList1 or {}
    	self._mountList2 = options.mountList2 or {}

    end

    self._ccbOwner.frame_tf_title:setString("一键换队")

	self:sortSubHeros()
	self:checkTeamUnlock()
	self:setTeamInfo()
end

function QUIDialogMetalCityQuickChangeTeam:viewDidAppear()
	QUIDialogMetalCityQuickChangeTeam.super.viewDidAppear(self)
end

function QUIDialogMetalCityQuickChangeTeam:viewWillDisappear()
  	QUIDialogMetalCityQuickChangeTeam.super.viewWillDisappear(self)
end

function QUIDialogMetalCityQuickChangeTeam:sortSubHeros()
    self._team1[2] = self._subHeros1 or {}
    self._team2[2] = self._subHeros2 or {}

    self._team1[3] = self._soulSpirit1 or {}
    self._team2[3] = self._soulSpirit2 or {}

    self._team1[4] = self._godarmList1 or {}
    self._team2[4] = self._godarmList2 or {}    

    self._team1[5] = self._mountList1 or {}
    self._team2[5] = self._mountList2 or {}  

end

function QUIDialogMetalCityQuickChangeTeam:checkTeamUnlock()
	self._helpTeamSlot = {}
	self._godArmTeamSlot = {}

	for i = 1, 2 do
		for j = 1, 4 do
			local unlock, unlockLevel = self:checkGodArmTeamUnlock(i, j)
			if self._godArmTeamSlot[i] == nil then
				self._godArmTeamSlot[i] = {}
			end
			self._godArmTeamSlot[i][j] = {unlock, unlockLevel}
		end
		for j = 1, 4 do
			local unlock, unlockLevel = self:checkHelpTeamUnlock(i, j)
			if self._helpTeamSlot[i] == nil then
				self._helpTeamSlot[i] = {}
			end
			self._helpTeamSlot[i][j] = {unlock, unlockLevel}
		end
	end
end

function QUIDialogMetalCityQuickChangeTeam:setTeamInfo()
	local height = 0
	if self._teamClient1 == nil then
		self._teamClient1 = QUIWidgetMetalCityQuickChangeTeam.new()
		self._teamClient1:addEventListener(QUIWidgetMetalCityQuickChangeTeam.EVENT_CLICK_DETAIL, handler(self, self._onClickDetail))
		self._teamClient1:addEventListener(QUIWidgetMetalCityQuickChangeTeam.EVENT_CLICK_TEAM_CHANGE, handler(self, self._onClickTeamChange))
		self._teamClient1:addEventListener(QUIWidgetMetalCityQuickChangeTeam.EVENT_CLICK_HERO_HEAD, handler(self, self._onClickHeroHead))
		self._ccbOwner.sheet:addChild(self._teamClient1)
	end
	self._teamClient1:setInfo(self._team1, 1, self._helpTeamSlot[1], self._fighterInfo, self._isStromArena, self._isDefence, self._isPVP, self._isTotemChallenge, self._isMockBattle)
	height = height + self._teamClient1:getContentSize().height

	if self._teamClient2 == nil then
		self._teamClient2 = QUIWidgetMetalCityQuickChangeTeam.new()
		self._teamClient2:addEventListener(QUIWidgetMetalCityQuickChangeTeam.EVENT_CLICK_DETAIL, handler(self, self._onClickDetail))
		self._teamClient2:addEventListener(QUIWidgetMetalCityQuickChangeTeam.EVENT_CLICK_TEAM_CHANGE, handler(self, self._onClickTeamChange))
		self._teamClient2:addEventListener(QUIWidgetMetalCityQuickChangeTeam.EVENT_CLICK_HERO_HEAD, handler(self, self._onClickHeroHead))
		self._ccbOwner.sheet:addChild(self._teamClient2)
	end
	self._teamClient2:setPositionY(-height)
	self._teamClient2:setInfo(self._team2, 2, self._helpTeamSlot[2], self._fighterInfo, self._isStromArena, self._isDefence, self._isPVP, self._isTotemChallenge, self._isMockBattle)
end

function QUIDialogMetalCityQuickChangeTeam:_onClickDetail(event)
	if event == nil then return end

	if self._isStromArena then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogStormArenaEnemyTeamInfo",
			options = {trialNum = event.trialNum, info = self._fighterInfo}}, {isPopCurrentDialog = false})
	elseif self._isTotemChallenge then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTotemChallengeEnemyTeamInfo",
			options = {trialNum = event.trialNum, info = self._fighterInfo}}, {isPopCurrentDialog = false})
	elseif self._isMockBattle then

	    local heros_ = {}
	    local subheros_ = {}
	    local sub2heros_ = {}
	    local sub3heros_ = {}
	    local mounts_ = {}
	    local godArm1List = {}
	    local teamIdx = event.trialNum or 1
		for i, value in pairs(self._fighterInfo.enemy_card_ids[teamIdx]) do
			local data_ = remote.mockbattle:getCardInfoByIndex(value.id)
			if value.team_index == remote.teamManager.TEAM_INDEX_MAIN then
	        	table.insert(heros_,data_ )
			elseif value.team_index == remote.teamManager.TEAM_INDEX_HELP then
	        	table.insert(subheros_, data_)
			elseif value.team_index == remote.teamManager.TEAM_INDEX_HELP2 then
	        	table.insert(sub2heros_, data_)
			elseif value.team_index == remote.teamManager.TEAM_INDEX_HELP3 then
	        	table.insert(sub3heros_, data_)
			elseif value.team_index == TEAM_INDEX_MOUNT then
	        	table.insert(mounts_, data_)
			elseif value.team_index == remote.teamManager.TEAM_INDEX_GODARM then
	        	table.insert(godArm1List, data_)
			end
		end

	    local options_ = {fighter = self._fighterInfo.fighter, isPVP = true ,heros = heros_ ,subheros = subheros_ 
	    ,sub2heros = sub2heros_ ,sub3heros = sub3heros_ ,mounts = mounts_ , godArm1List = godArm1List ,model = GAME_MODEL.MOCKBATTLE ,forceTitle="胜场 :" , isPVP = false , force = self._fighterInfo.fighter.winCount or 0 }

		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
	   		options = options_ }, {isPopCurrentDialog = false})
	else
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMetalCityBossIntroduce",
			options = {trialNum = event.trialNum, info = self._fighterInfo}}, {isPopCurrentDialog = false})
	end
end

function QUIDialogMetalCityQuickChangeTeam:_onClickTeamChange(event)
	if event == nil or self._isExchange then return end

	self:removeSelectEffect()
	local trialNum = event.trialNum
	if self._selectTrialNum ~= nil and self._selectTrialNum ~= trialNum then
		self._isExchange = true
		-- change main team
		for actorIndex = 1, 4 do
			self:exchangeTeamHero(self._selectTrialNum, 1, actorIndex, trialNum, 1, actorIndex)
		end

		-- change soul team
		local lockSoulNum = remote.soulSpirit:getTeamSpiritsMaxCount()
		for actorIndex = 1, lockSoulNum do
			self:exchangeTeamHero(self._selectTrialNum, 3, actorIndex, trialNum, 3, actorIndex)
		end

		-- change godarm team
		for actorIndex=1,4 do
			self:exchangeTeamHero(self._selectTrialNum, 4, actorIndex, trialNum, 4, actorIndex)
		end
		-- -- change help team
		for actorIndex = 1, 4 do
			self:exchangeTeamHero(self._selectTrialNum, 2, actorIndex, trialNum, 2, actorIndex)
		end
		-- -- change mount team
		for actorIndex = 1, 4 do
			self:exchangeTeamHero(self._selectTrialNum, 5, actorIndex, trialNum, 5, actorIndex)
		end

		for i = 1, 2 do
			if self["_teamClient"..i] then
				self["_teamClient"..i]:setChangeButton(true, true)
			end
		end
		RunActionDelayTime(self:getView(), function()
				self._selectTrialNum = nil
				self:setTeamInfo()
				self._isExchange = false
			end, 0.9)
	else
		for i = 1, 2 do
			if self["_teamClient"..i] then
				self["_teamClient"..i]:setChangeButton(i == trialNum, true)
			end
		end
		self._selectTrialNum = trialNum
	end
end

function QUIDialogMetalCityQuickChangeTeam:_onClickHeroHead(event)
	if event == nil or self._isExchange then return end

	local actorId = event.actorId
	local trialNum = event.trialNum
	local teamIndex = event.teamIndex
	local teamPos = event.teamPos
	local mount_need_change = false
	if self._selectHero ~= nil then
		-- 魂师不能魂灵换位置
		if (self._selectHeroTeamIndex == 3 or teamIndex == 3) and teamIndex ~= self._selectHeroTeamIndex then
			return
		end
		-- 魂师不能神器换位置
		if (self._selectHeroTeamIndex == 4 or teamIndex == 4) and teamIndex ~= self._selectHeroTeamIndex then
			return
		end
		-- 魂师不能暗器换位置
		if (self._selectHeroTeamIndex == 5 or teamIndex == 5) and teamIndex ~= self._selectHeroTeamIndex then
			return
		end
		-- 第二小队可能解锁位置不够
		if teamIndex == 2 then
			local slotInfo = self._helpTeamSlot[trialNum]
			if slotInfo and slotInfo[teamPos] == false then
				return
			end
		end

		-- 神器可能解锁位置不够
		if teamIndex == 4 then
			local slotInfo = self._godArmTeamSlot[trialNum]
			if slotInfo and slotInfo[teamPos] and slotInfo[teamPos][1] == false then
				return
			end

			local checkFunc = function(godarmList, targetId, excludeId)
				local num = 0
				local targetConfig = db:getCharacterByID(targetId)
				for _, v in pairs(godarmList) do
					if v ~= excludeId and v ~= targetId then
						local characherCOnfig = db:getCharacterByID(v)
						if characherCOnfig.label ~= nil and characherCOnfig.label == targetConfig.label then
							num = num + 1
						end	
					end
				end

				return num
			end

			printInfo("~~~~~~~~ actorId == %s ~~~~~~~", actorId)
			local samelabelNum = 0
			local godarmList1 = self._team1[teamIndex] or {}
			local godarmList2 = self._team2[teamIndex] or {}
			printInfo("~~~~~~~~ godarmList1 ~~~~~~~", godarmList1)
			printTable(godarmList1)
			printInfo("~~~~~~~~ godarmList2 ~~~~~~~", godarmList2)
			printTable(godarmList2)

			local selectGodArmList = godarmList1
			if self._selectHeroTrialNum == 2 then
				selectGodArmList = godarmList2
			end
			local selectGodArm = selectGodArmList[self._selectHero]

			local targetGodArmList = godarmList1
			printInfo("~~~~~~~ trialNum == %s ~~~~~~~", trialNum)
			if trialNum == 2 then
				targetGodArmList = godarmList2
			end
			printInfo("~~~~~~~~ selectGodArmList ~~~~~~~")
			printTable(selectGodArmList)
			printInfo("~~~~~~~~ targetGodArmList ~~~~~~~")
			printTable(targetGodArmList)
			printInfo("~~~~~~~ selectGodArm == %s ~~~~~~~", selectGodArm)

			samelabelNum = checkFunc(targetGodArmList, selectGodArm, actorId)
			printInfo("~~~~~~~ 1 samelabelNum == %s ~~~~~~~", samelabelNum)
			if samelabelNum < 2 and actorId then
				samelabelNum = checkFunc(selectGodArmList, actorId, selectGodArm)
				printInfo("~~~~~~~ 2 samelabelNum == %s ~~~~~~~", samelabelNum)
			end

			if samelabelNum >= 2 then
				app.tip:floatTip(QUIDialogMetalCityQuickChangeTeam.GODARM_SAME_FULL) 
				return
			end



		end
		if self._isMockBattle then --只有大师赛双队才需要判断
			--若主力魂师互换 且 不是同一对主力 更换主力相应位置的暗器
			if self._selectHeroTeamIndex == 1 and teamIndex == 1 then
				mount_need_change = true
			end

			--若更换暗器 需要判定 暗器所在位置是否存在魂师
			if self._selectHeroTeamIndex == 5 and teamIndex == 5  then
				local team1 = self["_team"..self._selectHeroTrialNum]
				local team2 = self["_team"..trialNum]
				if team1[1][self._selectHero] == nil  or team2[1][teamPos] == nil then
					app.tip:floatTip(QUIDialogMetalCityQuickChangeTeam.MOUNT_NOT_MATCH_HERO) 
					return
				end
			end
		end
		self:removeExchangeButton()
		self._isExchange = true
		if mount_need_change then
			self:exchangeMountByHeroChange(self._selectHeroTrialNum, self._selectHeroTeamIndex, self._selectHero, trialNum, teamIndex, teamPos)
		else
			self:exchangeTeamHero(self._selectHeroTrialNum, self._selectHeroTeamIndex, self._selectHero, trialNum, teamIndex, teamPos)
		end

		self:removeSelectEffect()
		RunActionDelayTime(self:getView(), function()
				self:setTeamInfo()
				self._isExchange = false
			end, 0.9)
	else
		self:removeExchangeButton()
		if actorId == nil then
			return
		end
		if self["_teamClient"..trialNum] then
			self["_teamClient"..trialNum]:hideSelectEffect()
			self["_teamClient"..trialNum]:showSelectEffect(teamIndex, teamPos)
		end
		self._selectHero = teamPos
		self._selectHeroTrialNum = trialNum
		self._selectHeroTeamIndex = teamIndex
	end
end

function QUIDialogMetalCityQuickChangeTeam:removeSelectEffect()
	for i = 1, 2 do
		if self["_teamClient"..i] then
			self["_teamClient"..i]:hideSelectEffect()
		end
	end
	self._selectHero = nil
	self._selectHeroTrialNum = nil
	self._selectHeroTeamIndex = nil
end

function QUIDialogMetalCityQuickChangeTeam:removeExchangeButton()
	for i = 1, 2 do
		if self["_teamClient"..i] then
			self["_teamClient"..i]:setChangeButton(false, false)
		end
	end
	self._selectTrialNum = nil
end

function QUIDialogMetalCityQuickChangeTeam:exchangeTeamHero(trialNum1, teamIndex1, pos1, trialNum2, teamIndex2, pos2)
	local team1 = self["_team"..trialNum1]
	local team2 = self["_team"..trialNum2]

	if team1[teamIndex1] == nil then team1[teamIndex1] = {} end
	if team2[teamIndex2] == nil then team2[teamIndex2] = {} end

	if teamIndex1 == 2 then
		local slotInfo = self._helpTeamSlot[trialNum1]
		if slotInfo and slotInfo[pos1] and slotInfo[pos1][1] == false then
			return
		end
	end
	if teamIndex2 == 2 then
		local slotInfo = self._helpTeamSlot[trialNum2]
		if slotInfo and slotInfo[pos2] and slotInfo[pos2][1] == false then
			return
		end
	end

	if team1[teamIndex1][pos1] and self["_teamClient"..trialNum1] then
		self["_teamClient"..trialNum1]:showHeroHeadEffect(teamIndex1, pos1)
	end
	if team2[teamIndex2][pos2] and self["_teamClient"..trialNum2] then
		self["_teamClient"..trialNum2]:showHeroHeadEffect(teamIndex2, pos2)
	end

	local temp = team1[teamIndex1][pos1]
	team1[teamIndex1][pos1] = team2[teamIndex2][pos2]
	team2[teamIndex2][pos2] = temp
end

function QUIDialogMetalCityQuickChangeTeam:exchangeMountByHeroChange(trialNum1, teamIndex1, pos1, trialNum2, teamIndex2, pos2)
	local team1 = self["_team"..trialNum1]
	local team2 = self["_team"..trialNum2]

	if team1[teamIndex1] == nil then team1[teamIndex1] = {} end
	if team2[teamIndex2] == nil then team2[teamIndex2] = {} end

	if teamIndex1 == 2 then
		local slotInfo = self._helpTeamSlot[trialNum1]
		if slotInfo and slotInfo[pos1] and slotInfo[pos1][1] == false then
			return
		end
	end
	if teamIndex2 == 2 then
		local slotInfo = self._helpTeamSlot[trialNum2]
		if slotInfo and slotInfo[pos2] and slotInfo[pos2][1] == false then
			return
		end
	end

	if team1[teamIndex1][pos1] and self["_teamClient"..trialNum1] then
		self["_teamClient"..trialNum1]:showHeroHeadEffect(teamIndex1, pos1)
	end
	if team2[teamIndex2][pos2] and self["_teamClient"..trialNum2] then
		self["_teamClient"..trialNum2]:showHeroHeadEffect(teamIndex2, pos2)
	end

	local temp = team1[teamIndex1][pos1]
	team1[teamIndex1][pos1] = team2[teamIndex2][pos2]
	team2[teamIndex2][pos2] = temp

	if team1[5] == nil then team1[5] = {} end
	if team2[5] == nil then team2[5] = {} end
	temp = team1[5][pos1]
	team1[5][pos1] = team2[5][pos2]
	team2[5][pos2] = temp

end

function QUIDialogMetalCityQuickChangeTeam:checkHelpTeamUnlock(trailNum, pos)
	local unlock = false
	local unlockLevel = 0
	local unlockNum = 1
	if trailNum == 1 then
		unlockNum = pos*2-1
	else
		unlockNum = pos*2
	end
	if self._isStromArena then
		unlock = app.unlock:checkLock("UNLOCK_STORM_HELP_"..unlockNum)
		unlockLevel = app.unlock:getConfigByKey("UNLOCK_STORM_HELP_"..unlockNum).team_level
	elseif self._isMockBattle then --  双队模拟赛不开启援助
		unlock =false
		unlockLevel = 999
	else
		unlock = app.unlock:checkLock("UNLOCK_METALCITY_HELP_"..unlockNum)
		unlockLevel = app.unlock:getConfigByKey("UNLOCK_METALCITY_HELP_"..unlockNum).team_level
	end
	
	return unlock, unlockLevel
end

function QUIDialogMetalCityQuickChangeTeam:checkGodArmTeamUnlock(trailNum, pos)
	local unlock = false
	local unlockLevel = 0
	if self._isMockBattle  then --  双队模拟赛只开放2个神器位置
		if pos > 2 then
			unlock =false
			unlockLevel = 999
		else
			unlock =true
			unlockLevel = 0
		end
	else
		unlock = app.unlock:checkLock("UNLOCK_GOD_ARM_"..trailNum.."_"..pos)
		unlockLevel = app.unlock:getConfigByKey("UNLOCK_GOD_ARM_"..trailNum.."_"..pos).team_level
	end
	return unlock, unlockLevel
end

function QUIDialogMetalCityQuickChangeTeam:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogMetalCityQuickChangeTeam:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogMetalCityQuickChangeTeam:viewAnimationOutHandler()
	local callback = self._callBack
	self:popSelf()
	if callback then
		scheduler.performWithDelayGlobal(callback, 0)
	end
end

return QUIDialogMetalCityQuickChangeTeam
