-- @Author: zhouxiaoshu
-- @Date:   2019-04-26 14:53:01
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-09-01 11:03:42
local QUIDialogBaseUnion = import("..dialogs.QUIDialogBaseUnion")
local QUIDialogConsortiaWar = class("QUIDialogConsortiaWar", QUIDialogBaseUnion)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUnionAvatar = import("...utils.QUnionAvatar")
local QUIWidgetFloorIcon = import("..widgets.QUIWidgetFloorIcon")
local QConsortiaWarDefenseArrangement = import("...arrangement.QConsortiaWarDefenseArrangement")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QUIWidgetConsortiaWarHall = import("..widgets.consortiaWar.QUIWidgetConsortiaWarHall")
local QUIWidgetAnimationPlayer = import("...ui.widgets.QUIWidgetAnimationPlayer")

function QUIDialogConsortiaWar:ctor(options)
	local ccbFile = "ccb/Dialog_UnionWar_main.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerRule", callback = handler(self, self._onTriggerRule)},
		{ccbCallbackName = "onTriggerRank", callback = handler(self, self._onTriggerRank)},
		{ccbCallbackName = "onTriggerRecord", callback = handler(self, self._onTriggerRecord)},
		{ccbCallbackName = "onTriggerBuff", callback = handler(self, self._onTriggerBuff)},
        {ccbCallbackName = "onTriggerTeam", callback = handler(self, self._onTriggerTeam)},
        {ccbCallbackName = "onTriggerAutoFill", callback = handler(self, self._onTriggerAutoFill)},
        {ccbCallbackName = "onTriggerClickPVP", callback = handler(self, self._onTriggerClickPVP)},  
        {ccbCallbackName = "onTriggerSetting", callback = handler(self, self._onTriggerSetting)}, 
	}
    QUIDialogConsortiaWar.super.ctor(self, ccbFile, callBacks, options)
    
    CalculateUIBgSize(self._ccbOwner.node_map_sp, 1280)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	
	self:setSocietyNameVisible(false)

    self._ccbOwner.touch_layer:setContentSize(CCSize(display.width, display.height))
	local touchSize = self._ccbOwner.touch_layer:getContentSize()
    self._touchLayer = QUIGestureRecognizer.new()
	self._touchLayer:setSlideRate(0.3)
	self._touchLayer:setAttachSlide(true)
	self._touchLayer:attachToNode(self._ccbOwner.touch_node, touchSize.width, touchSize.height, 0, 0, handler(self, self.onTouchEvent))
  
	self._totalHeight = (self._ccbOwner.map1:getContentSize().height + self._ccbOwner.map2:getContentSize().height)*1.25
  	self._orginPosY = self._ccbOwner.node_far:getPositionY()
    self._pageHeight = touchSize.height

	self._myHall = {}
	self._enemyHall = {}
	self._myOldScore = 0
	self._enemyOldScore = 0
	self._showEffect = false
	self._defaultPos = self:getOptions().defaultPos
	
	self._pvpNodePosX = self._ccbOwner.node_pvp:getPositionX()
end

function QUIDialogConsortiaWar:viewDidAppear()
	QUIDialogConsortiaWar.super.viewDidAppear(self)
	self:addBackEvent(false)
	
    self._touchLayer:enable()
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self.onTouchEvent))

	self._consortiaWarEventProxy = cc.EventProxy.new(remote.consortiaWar)
  	self._consortiaWarEventProxy:addEventListener(remote.consortiaWar.EVENT_CONSORTIA_WAR_UPDATE_INFO, handler(self,self.updateInfo))
   	self._consortiaWarEventProxy:addEventListener(remote.consortiaWar.EVENT_CONSORTIA_WAR_UPDATE_AWARD, handler(self, self.checkRewards))

	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)
	
	self:updateInfo()
	self:checkRewards()
end

function QUIDialogConsortiaWar:viewWillDisappear()
  	QUIDialogConsortiaWar.super.viewWillDisappear(self)
	self:removeBackEvent()

	self._touchLayer:removeAllEventListeners()
	self._touchLayer:disable()
	self._touchLayer:detach()

    self._consortiaWarEventProxy:removeAllEventListeners()

	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)

	if self._countDownScheduler ~= nil then
        scheduler.unscheduleGlobal(self._countDownScheduler)
        self._countDownScheduler = nil
    end 
end

function QUIDialogConsortiaWar:setSocietyTopBar(page)
	if page and page.topBar then
		local offsetX = -40
		if ENABLE_PVP_FORCE then
			offsetX = -70
		end
		page.topBar:showWithStyle({TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.BATTLE_FORCE_FOR_UNIONAR}, offsetX)
		page.topBar:updateForceTopBar()
	end
end

function QUIDialogConsortiaWar:exitFromBattleHandler()
	self._showEffect = true
	self:updateInfo()
end

--检查是否有奖励
function QUIDialogConsortiaWar:checkRewards()
	local awardInfo = remote.consortiaWar:getRewardInfo()
	if awardInfo then
		-- 重置攻破信息
		app:getUserOperateRecord():setRecordByType("consortia_war_hall_num", 0)

		local floorDialog = function()
			local rewardId = awardInfo.rewardId
			local callback = function()
				remote.consortiaWar:updateReward(rewardId)
			end
			if awardInfo.oldFloor < awardInfo.newFloor and awardInfo.floorReward ~= nil and awardInfo.floorReward ~= "" then
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogConsortiaWarFloorUpgrade",
					options = {rewardInfo = awardInfo, callBack = callback}},{isPopCurrentDialog = false} )
			else
				callback()
			end
		end
		local rewardType = awardInfo.rewardType or 0
		if rewardType == 0 and awardInfo.dailyReward and awardInfo.dailyReward ~= "" then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogConsortiaWarResultAwards",
				options = {awardInfo = awardInfo, callback = floorDialog}})
		elseif rewardType == 1 then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogConsortiaWarFloorInHerit",
				options = {rewardInfo = awardInfo, callback = function()
					awardInfo.oldFloor = 1
					floorDialog()
				end}},{isPopCurrentDialog = false})
		end
	elseif self._curState == remote.consortiaWar.STATE_FIGHT then
		self:checkShowHallBuff()
	elseif self._curState == remote.consortiaWar.STATE_NONE then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogConsortiaWarInvitation", 
			options = {callback = function()self:popSelf()end}})
	end
end

function QUIDialogConsortiaWar:checkShowHallBuff()
	local showNum = remote.consortiaWar:getBreakHallIdNum()
	local lastShowNum = app:getUserOperateRecord():getRecordByType("consortia_war_hall_num") or 0
	if showNum ~= 0 and showNum > lastShowNum then
		app:getUserOperateRecord():setRecordByType("consortia_war_hall_num", showNum)
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogConsortiaWarBuff"}, {isPopCurrentDialog = false})
	end
end

function QUIDialogConsortiaWar:updateInfo()
	local state, nextAt = remote.consortiaWar:getStateAndNextStateAt()
	self._curState = state
	self._curNextAt = nextAt

	self:initInfo()
	self:setMyInfo()

	if self._curState == remote.consortiaWar.STATE_READY or self._curState == remote.consortiaWar.STATE_READY_END then
		self._ccbOwner.node_introduction:setVisible(true)
		self._ccbOwner.node_team:setVisible(true)
		self._ccbOwner.node_desc:setVisible(true)

		if remote.user.userConsortia.rank == SOCIETY_OFFICIAL_POSITION.BOSS or remote.user.userConsortia.rank == SOCIETY_OFFICIAL_POSITION.ADJUTANT then
			self._ccbOwner.tf_auto_tips:setString("开战前自动填补空缺人员")
			self._ccbOwner.node_auto_btn:setVisible(true)
		else
			local myHall, isLeader = remote.consortiaWar:getMyHallInfo()
			if myHall then
				local hallConfig = remote.consortiaWar:getHallConfigByHallId(myHall.hallId)
				local str = ""
				if isLeader then
					str = string.format("您已被分配到：%s堂主", hallConfig.name)
				else
					str = string.format("您已被分配到：%s成员", hallConfig.name)
				end
				self._ccbOwner.tf_auto_tips:setString(str)
			else
				self._ccbOwner.tf_auto_tips:setString("您当前还未被分配")
			end
			self._ccbOwner.node_auto_btn:setVisible(false)
		end

		self:setSeasonInfo()
		self:showConsortiaWarReady()
		self:updateAutoFill()
		self:showDefenseForce()
		self:updateTimeInfo()

	elseif self._curState == remote.consortiaWar.STATE_FIGHT or self._curState == remote.consortiaWar.STATE_FIGHT_END then
		self._ccbOwner.node_union:setVisible(true)
		self._ccbOwner.node_score:setVisible(true)
		self._ccbOwner.node_bottom:setVisible(true)
		self._ccbOwner.node_count_down:setVisible(true)

		if self._curState == remote.consortiaWar.STATE_FIGHT then
			self._ccbOwner.tf_count_desc:setString("后剩余旗帜更多的宗门获胜")
			self._ccbOwner.node_fight_count:setVisible(true)
		else
			self._ccbOwner.tf_count_desc:setString("后进行下一轮匹配")
		end

		self:updateTimeInfo()
		self:showConsortiaWarFight()
		self:setBattleInfo()
	else
		self._ccbOwner.node_union:setVisible(true)
		self._ccbOwner.node_score:setVisible(true)
		self._ccbOwner.node_bottom:setVisible(true)
		self._ccbOwner.node_count_down:setVisible(true)
		self._ccbOwner.tf_count_desc:setString("后进行下一轮匹配")

		self:updateTimeInfo()
		self:showConsortiaWarFight()
	end

	if self._defaultPos then
		self:moveTo(self._defaultPos)
		self._defaultPos = nil
	end
end

function QUIDialogConsortiaWar:initInfo()
	self._ccbOwner.widget_node_team_bg:setVisible(false)
	self._ccbOwner.node_bottom:setVisible(false)
	self._ccbOwner.node_fight_count:setVisible(false)
	self._ccbOwner.node_count_down:setVisible(false)
	self._ccbOwner.node_season:setVisible(false)
	self._ccbOwner.node_team:setVisible(false)
	self._ccbOwner.node_introduction:setVisible(false)
	self._ccbOwner.node_union:setVisible(false)
	self._ccbOwner.node_score:setVisible(false)
	self._ccbOwner.node_desc:setVisible(false)
	self._ccbOwner.sp_record_tips:setVisible(false)
	self._ccbOwner.node_pvp:setVisible(false)
	self._ccbOwner.tf_defens_force:setString("")
end

function QUIDialogConsortiaWar:showDefenseForce()
	local teamInfo = remote.consortiaWar:getTeamInfo()
	local force = teamInfo.force or 0
	local num,unit = q.convertLargerNumber(force)
	self._ccbOwner.tf_defens_force:setString(num..(unit or ""))

	local fontInfo = db:getForceColorByForce(force, true)
	local color = string.split(fontInfo.force_color, ";")
	self._ccbOwner.tf_defens_force:setColor(ccc3(color[1], color[2], color[3]))

	self._ccbOwner.node_pvp:setVisible(ENABLE_PVP_FORCE)
	self._ccbOwner.node_pvp:setPositionX( self._pvpNodePosX + self._ccbOwner.tf_defens_force:getContentSize().width)
	self._ccbOwner.node_pvp_force:setVisible(ENABLE_PVP_FORCE)
	
	local isRedTips = remote.consortiaWar:checkTeamRedTips()
	self._ccbOwner.sp_team_tips:setVisible(isRedTips)
end

function QUIDialogConsortiaWar:setMyInfo()
	local consortiaWarInfo = remote.consortiaWar:getConsortiaWarInfo()
	local floor = consortiaWarInfo.floor or 1
	local curfloorInfo = remote.consortiaWar:getRankInfo(floor)
	local nextfloorInfo = remote.consortiaWar:getRankInfo(floor+1)
	self._ccbOwner.tf_union_rank:setString(curfloorInfo.name or "")

	local scoreStr = ""
	local score = consortiaWarInfo.score or 0
	local standard = nextfloorInfo.score_standard or 0
	if standard == 0 then
		scoreStr = score
	else
		scoreStr = score.."/"..standard
	end
	self._ccbOwner.tf_score:setString(scoreStr)
	
	if self._unionAvatar == nil then
		local icon = remote.union.consortia.icon
		self._unionAvatar = QUnionAvatar.new(icon)
		self._ccbOwner.node_icon:removeAllChildren()
		self._ccbOwner.node_icon:addChild(self._unionAvatar)
		self._ccbOwner.node_icon:setScale(0.6)
	end
	self._unionAvatar:setConsortiaWarFloor(floor)

	-- 段位icon
	if self._floorIcon == nil then
		self._floorIcon = QUIWidgetFloorIcon.new({isLarge = true})
		self._ccbOwner.node_floor:removeAllChildren()
		self._ccbOwner.node_floor:setScale(0.33)
 		self._ccbOwner.node_floor:addChild(self._floorIcon)
 	end
	self._floorIcon:setInfo(floor, "consortiaWar")
	self._floorIcon:setShowName(false)

	local myInfo = remote.consortiaWar:getMyInfo()
	local leftCount = remote.consortiaWar:getTotalFightCount() - (myInfo.fightCount or 0)
	self._ccbOwner.tf_attack_count:setString(leftCount)
end

function QUIDialogConsortiaWar:updateTimeInfo()
	local offsetTime = self._curNextAt - q.serverTime()
    local schedulerFunc
    schedulerFunc = function()
        if offsetTime >= 0 then
    		local timeStr = q.timeToHourMinuteSecond(offsetTime) 
            self._ccbOwner.tf_count:setString(timeStr)
			self._ccbOwner.tf_tips:setString("距离开战还有 "..timeStr)
			offsetTime = offsetTime - 1
        else
        	if self._countDownScheduler ~= nil then
		        scheduler.unscheduleGlobal(self._countDownScheduler)
		        self._countDownScheduler = nil
		    end 
    		local timeStr = q.timeToHourMinuteSecond(0) 
            self._ccbOwner.tf_count:setString(timeStr)
        end
    end

    if self._countDownScheduler ~= nil then
        scheduler.unscheduleGlobal(self._countDownScheduler)
        self._countDownScheduler = nil
    end 
    self._countDownScheduler = scheduler.scheduleGlobal(schedulerFunc, 1)
    schedulerFunc()
end

function QUIDialogConsortiaWar:setSeasonInfo()
	self._ccbOwner.node_bottom:setVisible(true)
	self._ccbOwner.node_season:setVisible(true)
	local startAt = remote.consortiaWar:getSeasonStartAt()
	local startStr = q.timeToYearMonthDay(startAt)
	local endStr = q.timeToYearMonthDay(startAt+8*WEEK)
    self._ccbOwner.tf_season_count:setString(startStr.."~"..endStr)
end

function QUIDialogConsortiaWar:updateAutoFill()
	local consortiaWarInfo = remote.consortiaWar:getConsortiaWarInfo()
	self._isHallAutoFill = consortiaWarInfo.isHallAutoFill or false
	self._ccbOwner.sp_select:setVisible(self._isHallAutoFill)
end

function QUIDialogConsortiaWar:showConsortiaWarReady()
	for i = 1, 4 do
		if not self._myHall[i] then
			local hall = QUIWidgetConsortiaWarHall.new()
			hall:addEventListener(QUIWidgetConsortiaWarHall.EVENT_CLICK_HALL, handler(self, self._myHallClickHandler))
			hall:addEventListener(QUIWidgetConsortiaWarHall.EVENT_CLICK_SELF, handler(self, self._myHallClickHandler))
			self._ccbOwner["node_my_"..i]:removeAllChildren()
			self._ccbOwner["node_my_"..i]:addChild(hall)
			self._myHall[i] = hall
		end
		local hallInfo = remote.consortiaWar:getHallInfoByHallId(i)
		self._myHall[i]:setInfo(hallInfo, true, true)
	end
end

function QUIDialogConsortiaWar:showConsortiaWarFight()
	for i = 1, 4 do
		if not self._myHall[i] then
			local hall = QUIWidgetConsortiaWarHall.new()
			hall:addEventListener(QUIWidgetConsortiaWarHall.EVENT_CLICK_HALL, handler(self, self._myHallClickHandler))
			hall:addEventListener(QUIWidgetConsortiaWarHall.EVENT_CLICK_SELF, handler(self, self._myHallClickHandler))
			self._ccbOwner["node_my_"..i]:removeAllChildren()
			self._ccbOwner["node_my_"..i]:addChild(hall)
			self._myHall[i] = hall
		end
		local hallInfo = remote.consortiaWar:getMyHallInfoByHallId(i)
		self._myHall[i]:setInfo(hallInfo, true)
	end
	for i = 1, 4 do
		if not self._enemyHall[i] then
			local hall = QUIWidgetConsortiaWarHall.new()
			hall:addEventListener(QUIWidgetConsortiaWarHall.EVENT_CLICK_HALL, handler(self, self._enemyHallClickHandler))
			self._ccbOwner["node_enemy_"..i]:removeAllChildren()
			self._ccbOwner["node_enemy_"..i]:addChild(hall)
			self._enemyHall[i] = hall
		end
		local hallInfo = remote.consortiaWar:getEnemyHallInfoByHallId(i)
		self._enemyHall[i]:setInfo(hallInfo, false)
		self._enemyHall[i]:showSetFireFlag(false)
	end

	local fireHallId = remote.consortiaWar:getSetFireFlagHallId()
	if fireHallId and self._enemyHall[fireHallId] then
		self._enemyHall[fireHallId]:showSetFireFlag(true)
	end

	local myScore = remote.consortiaWar:getTotalFlags(true)
	local enemyScore = remote.consortiaWar:getTotalFlags(false)
	if self._showEffect and (myScore ~= self._myOldScore or enemyScore ~= self._enemyOldScore) then
		self._myOldScore = myScore
		self._enemyOldScore = enemyScore

		local effect = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.node_score_effect:addChild(effect)
		effect:playAnimation("effects/zm_shuanguang_1.ccbi", function()
			end, function()
				self._ccbOwner.tf_num1:setString(myScore)
				self._ccbOwner.tf_num2:setString(enemyScore)
		    	effect:removeFromParentAndCleanup(true)
		    end)
	else
		self._ccbOwner.tf_num1:setString(myScore)
		self._ccbOwner.tf_num2:setString(enemyScore)
	end
	self._showEffect = false
end

function QUIDialogConsortiaWar:setBattleInfo()
	local myUnionInfo = remote.consortiaWar:getBattleConsortiaInfoList(true)
	local enemyUnionInfo = remote.consortiaWar:getBattleConsortiaInfoList(false)
	if not myUnionInfo or not next(myUnionInfo) or not enemyUnionInfo or not next(enemyUnionInfo) then
		app:alert({content = "当前界面由于时间变化，已经发生变动，请点击刷新", title = "系统提示", callback = function (state)
            if state == ALERT_TYPE.CONFIRM then
				remote.consortiaWar:consortiaWarGetMainInfoRequest(function()
					self:updateInfo()
				end)
            elseif state == ALERT_TYPE.CANCEL then
            	self:popSelf()
			end
        end})
        return
	end
	self._ccbOwner.tf_my_union_name:setString(myUnionInfo.consortiaName or "")
	self._ccbOwner.tf_my_env_name:setString(myUnionInfo.gameAreaName or "")
	self._ccbOwner.tf_enemy_union_name:setString(enemyUnionInfo.consortiaName or "")
	self._ccbOwner.tf_enemy_env_name:setString(enemyUnionInfo.gameAreaName or "")

	-- 段位icon
	if self._myFloor == nil then
		self._myFloor = QUIWidgetFloorIcon.new({isLarge = true})
		self._ccbOwner.node_my_floor:removeAllChildren()
 		self._ccbOwner.node_my_floor:addChild(self._myFloor)
 	end
	self._myFloor:setInfo(myUnionInfo.floor, "consortiaWar")
	self._myFloor:setShowName(false)

	-- 段位icon
	if self._enemyFloor == nil then
		self._enemyFloor = QUIWidgetFloorIcon.new({isLarge = true})
		self._ccbOwner.node_enemy_floor:removeAllChildren()
 		self._ccbOwner.node_enemy_floor:addChild(self._enemyFloor)
 	end
	self._enemyFloor:setInfo(enemyUnionInfo.floor, "consortiaWar")
	self._enemyFloor:setShowName(false)
end

function QUIDialogConsortiaWar:_myHallClickHandler(event)
	if not event.name or self._isMove then
		return
	end
	local hallId = event.hallId
	if self._curState == remote.consortiaWar.STATE_READY and (remote.user.userConsortia.rank == SOCIETY_OFFICIAL_POSITION.BOSS or remote.user.userConsortia.rank == SOCIETY_OFFICIAL_POSITION.ADJUTANT) then
		remote.consortiaWar:consortiaWarGetMemberListForDefenseRequest(function(data)
			remote.consortiaWar:setTempHallList()
        	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogConsortiaWarHallSetting",
        		options = {hallId = hallId}})
    	end) 
	else
		local findSelf = false
		if QUIWidgetConsortiaWarHall.EVENT_CLICK_SELF == event.name then
			findSelf = true
		end
		app:showCloudInterlude(function(cloudInterludeCallBack)
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogConsortiaWarHallInfo",
				options = {hallId = hallId, isMe = true, findSelf = findSelf, cloudInterludeCallBack = cloudInterludeCallBack}})
		end)
	end
end

function QUIDialogConsortiaWar:_enemyHallClickHandler(event)
	if not event.name or self._isMove then
		return
	end
	local hallId = event.hallId
	app:showCloudInterlude(function(cloudInterludeCallBack)
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogConsortiaWarHallInfo",
			options = {hallId = hallId, isMe = false, cloudInterludeCallBack = cloudInterludeCallBack}})
	end)
end

function QUIDialogConsortiaWar:onTouchEvent(event)
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
    	local handler = self:getScheduler().performWithDelayGlobal(function ()
    		self._isMove = false
    		end,0)
    end
end

function QUIDialogConsortiaWar:moveTo(posY)
	self:getOptions().defaultPos = posY
	self._ccbOwner.node_map:setPositionY(posY)
end

function QUIDialogConsortiaWar:_onTriggerTeam(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_team) == false then return end
    app.sound:playSound("common_small")

	local consortiaWarDefenseArrangement1 = QConsortiaWarDefenseArrangement.new({teamKey = remote.teamManager.CONSORTIA_WAR_DEFEND_TEAM1})
	local consortiaWarDefenseArrangement2 = QConsortiaWarDefenseArrangement.new({teamKey = remote.teamManager.CONSORTIA_WAR_DEFEND_TEAM2})
	local dialog = app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMetalCityTeamArrangement",
		options = {arrangement1 = consortiaWarDefenseArrangement1, arrangement2 = consortiaWarDefenseArrangement2, defense = true, isStromArena = true, widgetClass = "QUIWidgetStormArenaTeamBossInfo"}})
end

function QUIDialogConsortiaWar:_onTriggerAutoFill(event)
    app.sound:playSound("common_small")

	if remote.user.userConsortia.rank ~= SOCIETY_OFFICIAL_POSITION.BOSS and remote.user.userConsortia.rank ~= SOCIETY_OFFICIAL_POSITION.ADJUTANT then
		app.tip:floatTip("只有宗主和副宗主可以设置")
		return
	end

    local isAutoFill = not self._isHallAutoFill
	remote.consortiaWar:consortiaWarSetHallAutoFillRequest(isAutoFill, function()
		if self:safeCheck() then
			self:updateAutoFill()
		end
 	end)
end

function QUIDialogConsortiaWar:_onTriggerClickPVP(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_pvp) == false then return end
    app.sound:playSound("common_small")

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPVPPropTip", 
        options = {teamKey = remote.teamManager.CONSORTIA_WAR_DEFEND_TEAM1, teamKey2 = remote.teamManager.CONSORTIA_WAR_DEFEND_TEAM2, showTeam = true}}, {isPopCurrentDialog = false})
end

function QUIDialogConsortiaWar:_onTriggerBuff(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_buff) == false then return end
	app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogConsortiaWarBuff"}, {isPopCurrentDialog = false})
end

function QUIDialogConsortiaWar:_onTriggerRecord(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_record) == false then return end
    app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogConsortiaWarRecord"}, {isPopCurrentDialog = false})
end

function QUIDialogConsortiaWar:_onTriggerRank(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_rank) == false then return end
    app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRank", options = {initRank = "consortiaWar"}}, {isPopCurrentDialog = false})
end

function QUIDialogConsortiaWar:_onTriggerRule(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_help) == false then return end
    app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogConsortiaWarRule"})
end

function QUIDialogConsortiaWar:_onTriggerSetting( )
    app.sound:playSound("common_small")
	if remote.user.userConsortia.rank ~= SOCIETY_OFFICIAL_POSITION.BOSS and remote.user.userConsortia.rank ~= SOCIETY_OFFICIAL_POSITION.ADJUTANT then
		app.tip:floatTip("只有宗主和副宗主可以设置")
		return
	end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogConsortiaWarSetFire",options = {callBack = function( ... )
		if self:safeCheck() then
			self:updateInfo()
		end
	end}})
end

return QUIDialogConsortiaWar
