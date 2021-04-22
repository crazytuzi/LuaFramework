-- @Author: zhouxiaoshu
-- @Date:   2019-04-28 17:41:24
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-05-12 17:57:28
local QUIDialogBaseUnion = import("..dialogs.QUIDialogBaseUnion")
local QUIDialogConsortiaWarHallInfo = class("QUIDialogConsortiaWarHallInfo", QUIDialogBaseUnion)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetFloorIcon = import("..widgets.QUIWidgetFloorIcon")
local QConsortiaWarArrangement = import("...arrangement.QConsortiaWarArrangement")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QUIWidgetConsortiaWar = import("..widgets.consortiaWar.QUIWidgetConsortiaWar")
local QUIWidgetConsortiaWarHall = import("..widgets.consortiaWar.QUIWidgetConsortiaWarHall")
local QActorProp = import("...models.QActorProp")
local QRichText = import("...utils.QRichText")

local PLAYER_POS = {
	{250, -145},
	{155, -485},
	{420, -690},
	{250, -1000},
	{155, -1340},
	{420, -1545},
	{250, -1855},
	{155, -2195},
	{420, -2400},
	{250, -2710},
	{155, -3050},
	{420, -3290},
}
function QUIDialogConsortiaWarHallInfo:ctor(options)
	local ccbFile = "ccb/Dialog_UnionWar_Client.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerRule", callback = handler(self, self._onTriggerRule)},
		{ccbCallbackName = "onTriggerRank", callback = handler(self, self._onTriggerRank)},
		{ccbCallbackName = "onTriggerRecord", callback = handler(self, self._onTriggerRecord)},
		{ccbCallbackName = "onTriggerBuff", callback = handler(self, self._onTriggerBuff)},
        {ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerLeft)},
        {ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerRight)},
        {ccbCallbackName = "onTriggerClickPVP", callback = handler(self, self._onTriggerClickPVP)},   
	}
    QUIDialogConsortiaWarHallInfo.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	
    self._bgScale = CalculateUIBgSize(self._ccbOwner.node_map_sp, 1280)
	
	self:setSocietyNameVisible(false)
	self._ccbOwner.sp_record_tips:setVisible(false)

    self._ccbOwner.touch_layer:setContentSize(CCSize(display.width, display.height))
	local touchSize = self._ccbOwner.touch_layer:getContentSize()
    self._touchLayer = QUIGestureRecognizer.new()
	self._touchLayer:setSlideRate(0.3)
	self._touchLayer:setAttachSlide(true)
	self._touchLayer:attachToNode(self._ccbOwner.touch_node, touchSize.width, touchSize.height, 0, 0, handler(self, self.onTouchEvent))
  
	self._totalHeight = 0
  	self._orginPosY = self._ccbOwner.node_far:getPositionY()
    self._pageHeight = touchSize.height
    self._hallPosY = self._ccbOwner.node_cur_hall:getPositionY()

	self._cloudInterludeCallBack = options.cloudInterludeCallBack
	self._defaultPos = options.defaultPos
	self._hallId = options.hallId
	self._isMe = options.isMe
	self._findSelf = options.findSelf
	self._updateHallList = {}

	self:initLayer()
end

function QUIDialogConsortiaWarHallInfo:viewDidAppear()
	QUIDialogConsortiaWarHallInfo.super.viewDidAppear(self)
	self:addBackEvent(false)
	
    self._touchLayer:enable()
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self.onTouchEvent))

	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)

	self._curState = remote.consortiaWar:getStateAndNextStateAt()

	self:requestHallInfo()
end

function QUIDialogConsortiaWarHallInfo:viewWillDisappear()
  	QUIDialogConsortiaWarHallInfo.super.viewWillDisappear(self)
	self:removeBackEvent()

	self._touchLayer:removeAllEventListeners()
	self._touchLayer:disable()
	self._touchLayer:detach()

	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)
end

function QUIDialogConsortiaWarHallInfo:setSocietyTopBar(page)
	if page and page.topBar then
		local offsetX = -40
		if ENABLE_PVP_FORCE then
			offsetX = -70
		end
		page.topBar:showWithStyle({TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.BATTLE_FORCE_FOR_UNIONAR}, offsetX)
		page.topBar:updateForceTopBar()
	end
end

function QUIDialogConsortiaWarHallInfo:exitFromBattleHandler()
	self._defaultPos = self:getOptions().defaultPos
	self:updateInfo()
end

function QUIDialogConsortiaWarHallInfo:requestHallInfo()
	if self._updateHallList[self._hallId] then
		self:updateInfo()
	else
		remote.consortiaWar:consortiaWarGetOneHallBattleInfoRequest(self._hallId, self._isMe, function(data)
			if self:safeCheck() then
				self._updateHallList[self._hallId] = true
				self:updateInfo()

				if self._cloudInterludeCallBack then
					self._cloudInterludeCallBack()
					self._cloudInterludeCallBack = nil
				end
			end
		end, function()
			if self._cloudInterludeCallBack then
				self._cloudInterludeCallBack()
				self._cloudInterludeCallBack = nil
			end
		end)
	end
end

function QUIDialogConsortiaWarHallInfo:initLayer()
	self._ccbOwner.node_cur_hall:removeAllChildren()
	self._ccbOwner.sp_red_flag:setVisible(false)
	self._ccbOwner.sp_blue_flag:setVisible(false)
end

function QUIDialogConsortiaWarHallInfo:updateInfo()
	self:getOptions().hallId = self._hallId

	self:updateMainInfo()
	self:updatePlayerInfo()
end

function QUIDialogConsortiaWarHallInfo:updateMainInfo()
	local hallConfig = remote.consortiaWar:getHallConfigByHallId(self._hallId)
	if not self._isMe then
		if not self._richText then
			self._richText = QRichText.new({}, 250)
			self._richText:setAnchorPoint(ccp(0, 1))
	    	self._ccbOwner.node_desc:addChild(self._richText)
	    end
		local str1 = string.format("攻破敌方%s后：", hallConfig.name)
		self._richText:setString({
			{oType = "font", content = str1, size = 16, color = GAME_COLOR_SHADOW.normal, strokeColor = COLORS.Y},
	        {oType = "font", content = hallConfig.prop_name or "", size = 16, color = GAME_COLOR_SHADOW.stress, strokeColor = COLORS.Y},
	    })
	end
	self._gameAreaName = ""
	self._consortiaName = ""
	self._hallInfo = {}
	local totalCount = 0
	if self._curState == remote.consortiaWar.STATE_READY or self._curState == remote.consortiaWar.STATE_READY_END then
		self._hallInfo = remote.consortiaWar:getMyHallInfoByHallId(self._hallId)
		totalCount = remote.consortiaWar:getReadyHallTotalFlags(self._hallId)
		self._ccbOwner.node_red:setVisible(false)
		self._ccbOwner.node_blue:setVisible(true)
		
		local myUnionInfo = remote.consortiaWar:getConsortiaWarInfo()
		self._gameAreaName = myUnionInfo.gameAreaName or ""
		self._consortiaName = myUnionInfo.consortiaName or ""
		self._ccbOwner.tf_my_union_name:setString(myUnionInfo.consortiaName or "")
		self._ccbOwner.tf_my_env_name:setString(myUnionInfo.gameAreaName or "")
		-- 段位icon
		if self._myFloor == nil then
			self._myFloor = QUIWidgetFloorIcon.new({isLarge = true})
			self._ccbOwner.node_my_floor:removeAllChildren()
	 		self._ccbOwner.node_my_floor:addChild(self._myFloor)
	 	end
		self._myFloor:setInfo(myUnionInfo.floor, "consortiaWar")
		self._myFloor:setShowName(false)

	elseif self._isMe then
		self._hallInfo = remote.consortiaWar:getMyHallInfoByHallId(self._hallId)
		totalCount = remote.consortiaWar:getHallTotalFlags(true, self._hallId)
		self._ccbOwner.node_red:setVisible(false)
		self._ccbOwner.node_blue:setVisible(true)
		
		local myUnionInfo = remote.consortiaWar:getBattleConsortiaInfoList(true) or {}
		self._gameAreaName = myUnionInfo.gameAreaName or ""
		self._consortiaName = myUnionInfo.consortiaName or ""
		self._ccbOwner.tf_my_union_name:setString(myUnionInfo.consortiaName or "")
		self._ccbOwner.tf_my_env_name:setString(myUnionInfo.gameAreaName or "")
		-- 段位icon
		if self._myFloor == nil then
			self._myFloor = QUIWidgetFloorIcon.new({isLarge = true})
			self._ccbOwner.node_my_floor:removeAllChildren()
	 		self._ccbOwner.node_my_floor:addChild(self._myFloor)
	 	end
		self._myFloor:setInfo(myUnionInfo.floor, "consortiaWar")
		self._myFloor:setShowName(false)

	else
		self._hallInfo = remote.consortiaWar:getEnemyHallInfoByHallId(self._hallId)
		totalCount = remote.consortiaWar:getHallTotalFlags(false, self._hallId)
		self._ccbOwner.node_red:setVisible(true)
		self._ccbOwner.node_blue:setVisible(false)
		
		local enemyUnionInfo = remote.consortiaWar:getBattleConsortiaInfoList(false) or {}
		self._gameAreaName = enemyUnionInfo.gameAreaName or ""
		self._consortiaName = enemyUnionInfo.consortiaName or ""
		self._ccbOwner.tf_enemy_union_name:setString(enemyUnionInfo.consortiaName or "")
		self._ccbOwner.tf_enemy_env_name:setString(enemyUnionInfo.gameAreaName or "")

		-- 段位icon
		if self._enemyFloor == nil then
			self._enemyFloor = QUIWidgetFloorIcon.new({isLarge = true})
			self._ccbOwner.node_enemy_floor:removeAllChildren()
	 		self._ccbOwner.node_enemy_floor:addChild(self._enemyFloor)
	 	end
		self._enemyFloor:setInfo(enemyUnionInfo.floor, "consortiaWar")
		self._enemyFloor:setShowName(false)
	end

	-- 堂建筑
	if not self._curHall then
		local hall = QUIWidgetConsortiaWarHall.new()
		hall:setTouchEnable(false)
		hall:hideHallInfo()
	 	self._ccbOwner.node_cur_hall:addChild(hall)
	 	self._curHall = hall
	end
	self._curHall:setInfo(self._hallInfo, self._isMe)

	local myInfo = remote.consortiaWar:getMyInfo()
	local leftCount = remote.consortiaWar:getTotalFightCount() - (myInfo.fightCount or 0)
	self._ccbOwner.tf_attack_count:setString(leftCount)

	local aliveCount = 0
	for i, member in pairs(self._hallInfo.memberList or {}) do
		if not member.isBreakThrough then
			aliveCount = aliveCount + 1
		end
	end
	local posY = 0
	if aliveCount >= 5 then
		posY = 0
	elseif aliveCount >= 1 then
		posY = 10
	else
		posY = 20
	end
	self._ccbOwner.node_cur_hall:setPositionY(self._hallPosY+posY)

	self._ccbOwner.tf_hall_name:setString(hallConfig.name.."人数：")
	local numStr = string.format("%d/%d", aliveCount, remote.consortiaWar:getHallMemberCount())
	self._ccbOwner.tf_num:setString(numStr)
	self._ccbOwner.tf_flag_count:setString(totalCount)

	self._ccbOwner.sp_red_flag:setVisible(not self._isMe)
	self._ccbOwner.sp_blue_flag:setVisible(self._isMe)
end
	
-- 成员信息
function QUIDialogConsortiaWarHallInfo:updatePlayerInfo()
	local hallPlayers = self._hallInfo.memberList or {}
	table.sort( hallPlayers, function(a, b)
			if a.isLeader ~= b.isLeader then
				return a.isLeader == true
			else
				return a.memberFighter.force > b.memberFighter.force
			end
		end)
	self._virtualFrame = {}
	self._ccbOwner.node_avatar:removeAllChildren()
	local index = 1
	local myPos = 1
	for i, value in pairs(hallPlayers) do
		value.gameAreaName = self._gameAreaName
		value.consortiaName = self._consortiaName
		local posX = PLAYER_POS[index][1]
		local posY = PLAYER_POS[index][2] * self._bgScale - 20
		local userCell = QUIWidgetConsortiaWar.new()
		userCell:addEventListener(QUIWidgetConsortiaWar.EVENT_BATTLE, handler(self, self.startBattleHandler))
		userCell:addEventListener(QUIWidgetConsortiaWar.EVENT_VISIT, handler(self, self.clickCellHandler))
		userCell:addEventListener(QUIWidgetConsortiaWar.EVENT_QUICK_BATTLE, handler(self, self.qucikBattleHandler))
		userCell:setScale(0.8)
		userCell:setIndex(index)
		userCell:setInfo(value, self._isMe)
		userCell:setPosition(ccp(posX, posY))
		userCell:setVisible(false)
		self._ccbOwner.node_avatar:addChild(userCell)

		if remote.user.userId == value.memberId then
			myPos = index
		end
		table.insert(self._virtualFrame, {widget = userCell, posX = posX, posY = posY })
		index = index + 1
	end

	local hallFlagInfo = {
		gameAreaName = self._gameAreaName,
		consortiaName = self._consortiaName,
		pickFlagCount = remote.consortiaWar.FLAG_COUNT - (self._hallInfo.pickFlagCount or 0),
	}
	-- 散落旗帜
	local posX = PLAYER_POS[index][1]
	local posY = PLAYER_POS[index][2] * self._bgScale-20
	local userCell = QUIWidgetConsortiaWar.new()
	userCell:addEventListener(QUIWidgetConsortiaWar.EVENT_BATTLE, handler(self, self.startBattleHandler))
	userCell:addEventListener(QUIWidgetConsortiaWar.EVENT_VISIT, handler(self, self.clickCellHandler))
	userCell:setScale(0.8)
	userCell:setIndex(index)
	userCell:setFlagInfo(hallFlagInfo, self._isMe)
	userCell:setPosition(ccp(posX, posY))
	userCell:setVisible(false)
	self._ccbOwner.node_avatar:addChild(userCell)
	table.insert(self._virtualFrame, {widget = userCell, posX =posX, posY = posY })

	self._totalHeight = -PLAYER_POS[index][2] * self._bgScale + 220
	if self._findSelf and myPos > 1 then
		self._defaultPos = -PLAYER_POS[myPos][2] * self._bgScale - 220
	end
	if self._defaultPos ~= nil then
		self:moveTo(self._defaultPos)
		self._defaultPos = nil
	else
		self:moveTo(self._orginPosY)
	end
end

function QUIDialogConsortiaWarHallInfo:onTouchEvent(event)
	if event == nil or event.name == nil then
        return
    end
    
    if event.name == "began" then
  		self._startY = event.y
  		self._pageY = self._ccbOwner.node_map:getPositionY()
    elseif event.name == "moved" then
    	if self._startY == nil or self._pageY == nil then
    		return
    	end
    	local offsetY = self._pageY + event.y - self._startY
        if math.abs(event.y - self._startY) > 10 then
            self._isMove = true
        end
        if self._totalHeight >= self._pageHeight then
			if offsetY > self._orginPosY + (self._totalHeight - self._pageHeight) then
				offsetY = self._orginPosY + (self._totalHeight - self._pageHeight)
			elseif offsetY < self._orginPosY then
				offsetY = self._orginPosY
			end
			self:moveTo(offsetY)
		end
	elseif event.name == "ended" then
    	self:getScheduler().performWithDelayGlobal(function ()
    		self._isMove = false
    	end, 0)
    end
end

function QUIDialogConsortiaWarHallInfo:moveTo(posY)
	self:getOptions().defaultPos = posY
	self._ccbOwner.node_map:setPositionY(posY)
	for _, frame in ipairs(self._virtualFrame) do
		local curPosY = frame.posY + posY
		if curPosY <= (self._orginPosY + 150) and curPosY >= (self._orginPosY - self._pageHeight - 150) then
			frame.widget:setVisible(true)
		else
			frame.widget:setVisible(false)
		end
	end
end

function QUIDialogConsortiaWarHallInfo:qucikBattleHandler( event)
	-- 队友查看
	if self._isMe then
		self:clickCellHandler(event)
		return
	end

	if not event.name or self._isMove then
		return
	end
    app.sound:playSound("common_small")

	local myInfo = remote.consortiaWar:getMyInfo()
    local fightCount = myInfo.fightCount or 0
	local leftCount = remote.consortiaWar:getTotalFightCount() - fightCount
	if leftCount <= 0 then
		app.tip:floatTip("今日战斗次数不足！")
		return
	end

	self._curState = remote.consortiaWar:getStateAndNextStateAt()
	if self._curState ~= remote.consortiaWar.STATE_FIGHT then
		app.tip:floatTip("今日战斗已结束")
		return
	end

	-- 散落旗帜
	if event.isFlag then
		-- 成员信息
		if self._hallInfo.pickFlagCount >= remote.consortiaWar.FLAG_COUNT then
			local errorCode = db:getErrorCode("CONSORTIA_WAR_CONSORTIA_PICK_LIMIT")
        	app.tip:floatTip(errorCode.desc)
			return
		end

		app:alert({content = "##n是否消耗##e一次##n战斗次数，摧毁##e2面##n敌方散落在地的战旗？（不需要战斗即可成功摧毁，建议分配宗门中战力较低的成员进行）", title = "摧毁战旗", callback = function (state)
            if state == ALERT_TYPE.CONFIRM then
            	local oldFlags = remote.consortiaWar:getHallTotalFlags(false, self._hallId)
            	local newFlags = oldFlags - 2
				remote.consortiaWar:consortiaWarPickUpFlagRequest(self._hallId, function(data)
					local rewardConfig = remote.consortiaWar:getRewardConfig()
					local luckyDraw = db:getLuckyDraw(rewardConfig.reward_win_2) or {}
				    local index = 1
				    local awards = {}
			        while luckyDraw["type_"..index] do
		                if luckyDraw["probability_"..index] == -1 then
		                    table.insert(awards, {id = luckyDraw["id_"..index], typeName = luckyDraw["type_"..index], count = luckyDraw["num_"..index]})
		                end
			            index = index + 1
			        end

					local info = {
						oldFlags = oldFlags,
						newFlags = newFlags,
						awards = awards,
					}
					local callback = function()
						remote.consortiaWar:consortiaWarGetOneHallBattleInfoRequest(self._hallId, self._isMe, function(data)
							if self:safeCheck() then
								self._updateHallList[self._hallId] = true
								self._defaultPos = self:getOptions().defaultPos
								self:updateInfo()
							end
						end)
					end
					app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogConsortiaWarHallBreakSuccess",
    					options = {info = info, callback = callback}}, {isPopCurrentDialog = false})
				end)
            end
        end, colorful = true})
		return
	end

	-- 成员信息
	if event.info.remainFlagCount <= 0 then
		app.tip:floatTip("该成员已被消灭！")
		return
	end	
	local updateCallback = function()
		remote.consortiaWar:consortiaWarGetOneHallBattleInfoRequest(self._hallId, self._isMe, function(data)
			if self:safeCheck() then
				self._updateHallList[self._hallId] = true
				self._defaultPos = self:getOptions().defaultPos
				self:updateInfo()
			end
		end)
	end
	local success = function(data)
		if self:safeCheck() then
			self.rivalId = nil
			local batchAwards = {}
			local awards = {}
			local scoreList = data.gfEndResponse.scoreList or {}
			local rewadrStr = data.gfEndResponse.consortiaWarFightEndResponse.reward
			local breakThroughFlagCount = data.gfEndResponse.consortiaWarFightEndResponse.breakThroughFlagCount or 0
			if rewadrStr then
				local awadrsTbl = string.split(rewadrStr,";")
				for _,value in pairs(awadrsTbl or {}) do
					if value and value ~= "" then
						local tbl = string.split(value,"^")
			            local typeName = remote.items:getItemType(tbl[1]) or ITEM_TYPE.ITEM
			            table.insert(awards, {typeName = typeName, id = tbl[1], count = tonumber(tbl[2]) })
			        end
				end
			end
			local winCount = 0
			for _,v in pairs(scoreList) do
				if v == true then
					winCount = winCount + 1
				end
			end
			local text = "魂师大人，本次战斗您并未战胜对手，摧毁旗帜%d面，要再接再厉哦～"
			local isWin = false
			if winCount == 1 then
				isWin = true
				text = "魂师大人，本次战斗势均力敌，最终比分1：1，摧毁旗帜%d面，以下是您的奖励哟～"
			elseif winCount >= 2 then
				isWin = true
				text = "魂师大人，本次战斗您不费吹灰之力就以2：0战胜了对方，摧毁旗帜%d面，以下是您的奖励哟～"
			end
			if isWin then
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogWin", 
                    options = {awards = awards, text = string.format(text,breakThroughFlagCount) ,callback = function()
			    		if self:safeCheck() then
			    			self._isManualRefresh = true
							updateCallback()
						end
                    end}}, {isPopCurrentDialog = true})
			else
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogLose", 
				options = {awards = awards, text = string.format(text,breakThroughFlagCount),callback = function()
		    		if self:safeCheck() then
						updateCallback()
					end
	            end}}, {isPopCurrentDialog = true})	

			end
		end
	end

	local userId = event.info.memberId
	remote.consortiaWar:consortiaWarQueryFighterRequest(userId, function(data)
		local rivalsFight = data.consortiaWarQueryFighterResponse.fighter or {}
		remote.teamManager:sortTeam(rivalsFight.heros, true)
		remote.teamManager:sortTeam(rivalsFight.subheros, true)
		remote.teamManager:sortTeam(rivalsFight.sub2heros, true)
		remote.teamManager:sortTeam(rivalsFight.main1Heros, true)
		remote.teamManager:sortTeam(rivalsFight.sub1heros, true)

		local myTeamInfo = remote.consortiaWar:getTeamInfo()
		local consortiaWarArrangement1 = QConsortiaWarArrangement.new({hallId = self._hallId, myInfo = myTeamInfo, rivalInfo = rivalsFight, teamKey = remote.teamManager.CONSORTIA_WAR_ATTACK_TEAM1})
		local consortiaWarArrangement2 = QConsortiaWarArrangement.new({hallId = self._hallId, myInfo = myTeamInfo, rivalInfo = rivalsFight, teamKey = remote.teamManager.CONSORTIA_WAR_ATTACK_TEAM2})
		local heroIdList1 = consortiaWarArrangement1:getHeroIdList()
		local heroIdList2 = consortiaWarArrangement2:getHeroIdList()	

		local callback = function( )
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMetalCityTeamArrangement",
				options = {arrangement1 = consortiaWarArrangement1, arrangement2 = consortiaWarArrangement2, isStromArena = true, widgetClass = "QUIWidgetStormArenaTeamBossInfo", fighterInfo = rivalsFight}})
		end
		if not consortiaWarArrangement1:teamValidity(heroIdList1[1].actorIds, 1, callback) then 
			return
		end
		if not consortiaWarArrangement2:teamValidity(heroIdList2[1].actorIds, 2, callback) then 
			return
		end		


		local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.CONSORTIA_WAR_ATTACK_TEAM1, false)
		local soulMaxNum = teamVO:getSpiritsMaxCountByIndex(1)
		local numSpiritInOne = heroIdList1[1].spiritIds == nil and 0 or #heroIdList1[1].spiritIds
		local numSpiritInTwo = heroIdList2[1].spiritIds == nil and 0 or #heroIdList2[1].spiritIds
	    if soulMaxNum > 0 
	    	and ((heroIdList1[1].spiritIds ~= nil and #heroIdList1[1].spiritIds < soulMaxNum) or (heroIdList2[1].spiritIds ~= nil and #heroIdList2[1].spiritIds < soulMaxNum)) 
	    	and (#remote.soulSpirit:getMySoulSpiritInfoList() - numSpiritInOne - numSpiritInTwo) > 0 then
	        app:alert({content="有主力魂灵未上阵，确定开始战斗吗？",title="系统提示", callback = function (state)
	            if state == ALERT_TYPE.CONFIRM then
	                consortiaWarArrangement1:startBattle(heroIdList1, heroIdList2,true,success,updateCallback)
	            end
	        end})
	    else
	    	consortiaWarArrangement1:startBattle(heroIdList1, heroIdList2, true,success,updateCallback)
	    end
	end)	
end

function QUIDialogConsortiaWarHallInfo:startBattleHandler(event)
	-- 队友查看
	if self._isMe then
		self:clickCellHandler(event)
		return
	end

	if not event.name or self._isMove then
		return
	end
    app.sound:playSound("common_small")

	local myInfo = remote.consortiaWar:getMyInfo()
    local fightCount = myInfo.fightCount or 0
	local leftCount = remote.consortiaWar:getTotalFightCount() - fightCount
	if leftCount <= 0 then
		app.tip:floatTip("今日战斗次数不足！")
		return
	end

	self._curState = remote.consortiaWar:getStateAndNextStateAt()
	if self._curState ~= remote.consortiaWar.STATE_FIGHT then
		app.tip:floatTip("今日战斗已结束")
		return
	end

	-- 散落旗帜
	if event.isFlag then
		-- 成员信息
		if self._hallInfo.pickFlagCount >= remote.consortiaWar.FLAG_COUNT then
			local errorCode = db:getErrorCode("CONSORTIA_WAR_CONSORTIA_PICK_LIMIT")
        	app.tip:floatTip(errorCode.desc)
			return
		end

		app:alert({content = "##n是否消耗##e一次##n战斗次数，摧毁##e2面##n敌方散落在地的战旗？（不需要战斗即可成功摧毁，建议分配宗门中战力较低的成员进行）", title = "摧毁战旗", callback = function (state)
            if state == ALERT_TYPE.CONFIRM then
            	local oldFlags = remote.consortiaWar:getHallTotalFlags(false, self._hallId)
            	local newFlags = oldFlags - 2
				remote.consortiaWar:consortiaWarPickUpFlagRequest(self._hallId, function(data)
					local rewardConfig = remote.consortiaWar:getRewardConfig()
					local luckyDraw = db:getLuckyDraw(rewardConfig.reward_win_2) or {}
				    local index = 1
				    local awards = {}
			        while luckyDraw["type_"..index] do
		                if luckyDraw["probability_"..index] == -1 then
		                    table.insert(awards, {id = luckyDraw["id_"..index], typeName = luckyDraw["type_"..index], count = luckyDraw["num_"..index]})
		                end
			            index = index + 1
			        end

					local info = {
						oldFlags = oldFlags,
						newFlags = newFlags,
						awards = awards,
					}
					local callback = function()
						remote.consortiaWar:consortiaWarGetOneHallBattleInfoRequest(self._hallId, self._isMe, function(data)
							if self:safeCheck() then
								self._updateHallList[self._hallId] = true
								self._defaultPos = self:getOptions().defaultPos
								self:updateInfo()
							end
						end)
					end
					app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogConsortiaWarHallBreakSuccess",
    					options = {info = info, callback = callback}}, {isPopCurrentDialog = false})
				end)
            end
        end, colorful = true})
		return
	end

	-- 成员信息
	if event.info.remainFlagCount <= 0 then
		app.tip:floatTip("该成员已被消灭！")
		return
	end

	local userId = event.info.memberId
	remote.consortiaWar:consortiaWarQueryFighterRequest(userId, function(data)
		local rivalsFight = data.consortiaWarQueryFighterResponse.fighter or {}
		remote.teamManager:sortTeam(rivalsFight.heros, true)
		remote.teamManager:sortTeam(rivalsFight.subheros, true)
		remote.teamManager:sortTeam(rivalsFight.sub2heros, true)
		remote.teamManager:sortTeam(rivalsFight.main1Heros, true)
		remote.teamManager:sortTeam(rivalsFight.sub1heros, true)
		
		local myTeamInfo = remote.consortiaWar:getTeamInfo()
		local consortiaWarArrangement1 = QConsortiaWarArrangement.new({hallId = self._hallId, myInfo = myTeamInfo, rivalInfo = rivalsFight, teamKey = remote.teamManager.CONSORTIA_WAR_ATTACK_TEAM1})
		local consortiaWarArrangement2 = QConsortiaWarArrangement.new({hallId = self._hallId, myInfo = myTeamInfo, rivalInfo = rivalsFight, teamKey = remote.teamManager.CONSORTIA_WAR_ATTACK_TEAM2})
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMetalCityTeamArrangement",
			options = {arrangement1 = consortiaWarArrangement1, arrangement2 = consortiaWarArrangement2, isStromArena = true, widgetClass = "QUIWidgetStormArenaTeamBossInfo", fighterInfo = rivalsFight}})
	end)
end


function QUIDialogConsortiaWarHallInfo:clickCellHandler(event)
   	if not event.name or self._isMove then
		return
	end
	app.sound:playSound("common_small")
	if event.isFlag then
		app.tip:floatTip("散落旗帜")
		return
	end
	local gameAreaName = self._gameAreaName
	local consortiaName = self._consortiaName
    local userId = event.info.memberId
	remote.consortiaWar:consortiaWarQueryFighterRequest(userId, function(data)
		local fighterInfo = data.consortiaWarQueryFighterResponse.fighter or {}
		fighterInfo.game_area_name = gameAreaName
		fighterInfo.consortiaName = consortiaName
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogStromArenaPlayerInfo",
    		options = {fighterInfo = fighterInfo, isPVP = true}}, {isPopCurrentDialog = false})
	end)
end

function QUIDialogConsortiaWarHallInfo:_onTriggerLeft(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_left) == false then return end
	app.sound:playSound("common_small")

	self._hallId = self._hallId - 1
	if self._hallId < 1 then
		self._hallId = 4
	end
	self:requestHallInfo()
end

function QUIDialogConsortiaWarHallInfo:_onTriggerRight(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_right) == false then return end
	app.sound:playSound("common_small")

	self._hallId = self._hallId + 1
	if self._hallId > 4 then
		self._hallId = 1
	end
	self:requestHallInfo()
end

function QUIDialogConsortiaWarHallInfo:_onTriggerClickPVP(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_pvp) == false then return end
    app.sound:playSound("common_small")

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPVPPropTip", 
        options = {teamKey = remote.teamManager.CONSORTIA_WAR_DEFEND_TEAM1, teamKey2 = remote.teamManager.CONSORTIA_WAR_DEFEND_TEAM2, showTeam = true}}, {isPopCurrentDialog = false})
end

function QUIDialogConsortiaWarHallInfo:_onTriggerBuff(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_buff) == false then return end
	app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogConsortiaWarBuff"}, {isPopCurrentDialog = false})
end

function QUIDialogConsortiaWarHallInfo:_onTriggerRecord(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_record) == false then return end
    app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogConsortiaWarRecord"}, {isPopCurrentDialog = false})
end

function QUIDialogConsortiaWarHallInfo:_onTriggerRank(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_rank) == false then return end
    app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRank", options = {initRank = "consortiaWar"}}, {isPopCurrentDialog = false})
end

function QUIDialogConsortiaWarHallInfo:_onTriggerRule(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_help) == false then return end
    app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogConsortiaWarRule"})
end

return QUIDialogConsortiaWarHallInfo
