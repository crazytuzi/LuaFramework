-- @Author: zhouxiaoshu
-- @Date:   2019-09-07 17:40:44
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-05-16 14:05:41
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSotoTeam = class("QUIDialogSotoTeam", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QVIPUtil = import("...utils.QVIPUtil")
local QQuickWay = import("...utils.QQuickWay")
local QSotoTeamArrangement = import("...arrangement.QSotoTeamArrangement")
local QSotoTeamDefenseArrangement = import("...arrangement.QSotoTeamDefenseArrangement")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIDialogBuyCount = import("..dialogs.QUIDialogBuyCount")
local QUIWidgetSotoTeam = import("..widgets.QUIWidgetSotoTeam")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")

local PI = 3.14
local MISS_WIDTH = 68

function QUIDialogSotoTeam:ctor(options)
 	local ccbFile = "ccb/Dialog_SotoTeam.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)},
        {ccbCallbackName = "onTriggerRecord", callback = handler(self, self._onTriggerRecord)},
        {ccbCallbackName = "onTriggerRank", callback = handler(self, self._onTriggerRank)},
        {ccbCallbackName = "onTriggerShop", callback = handler(self, self._onTriggerShop)},
        {ccbCallbackName = "onTriggerScore", callback = handler(self, self._onTriggerScore)},
        {ccbCallbackName = "onTriggerTeam", callback = handler(self, self._onTriggerTeam)},
        {ccbCallbackName = "onTriggerRefresh", callback = handler(self, self._onTriggerRefresh)},
        {ccbCallbackName = "onTriggerPlus", callback = handler(self, self._onTriggerPlus)},
        {ccbCallbackName = "onTriggerClickPVP", callback = handler(self, self._onTriggerClickPVP)},   
        {ccbCallbackName = "onTriggerSeasonTips", callback = handler(self, self._onTriggerSeasonTips)},   
    }
    QUIDialogSotoTeam.super.ctor(self, ccbFile, callBacks, options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.setAllUIVisible then page:setAllUIVisible(false) end
	if page.setScalingVisible then page:setScalingVisible(false) end
	if page.topBar then page.topBar:showWithMainBar() end

    CalculateUIBgSize(self._ccbOwner.node_map, 1280)

    self._touchWidth = self._ccbOwner.touch_layer:getContentSize().width
	self._touchHeight = self._ccbOwner.touch_layer:getContentSize().height
    self._touchLayer = QUIGestureRecognizer.new()
	self._touchLayer:setSlideRate(0.3)
	self._touchLayer:setAttachSlide(true)
	self._touchLayer:attachToNode(self._ccbOwner.touch_node, self._touchWidth, self._touchHeight, self._ccbOwner.touch_layer:getPositionX(),
		self._ccbOwner.touch_layer:getPositionY(), handler(self, self.onTouchEvent))

	local config = db:getConfiguration()
	self._configTotalCount = config.soto_team_free_fight_count.value or 0
	self._configRefreshFreeCount = config.soto_team_free_refresh_time.value or 0
	self._configRefreshToken = config.soto_team_time_cost.value or 0

    self._pvpNodePosX = self._ccbOwner.node_pvp:getPositionX()
    
    --初始化动画
	local act_path = QResPath("soto_ani")[1]
	local fcaAnimation = QUIWidgetFcaAnimation.new(act_path, "res")
    self._ccbOwner.node_effect_change:removeAllChildren()
    self._ccbOwner.node_effect_change:addChild(fcaAnimation)
    fcaAnimation:playAnimation("animation", true)

	self:resetAll()



end

function QUIDialogSotoTeam:viewDidAppear()
    QUIDialogSotoTeam.super.viewDidAppear(self)
  	self:addBackEvent(false)

	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)

    self._touchLayer:enable()
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self.onTouchEvent))

    self.sotoTeamEventProxy = cc.EventProxy.new(remote.sotoTeam)
    self.sotoTeamEventProxy:addEventListener(remote.sotoTeam.EVENT_SOTO_TEAM_MY_INFO, handler(self, self._onRefresh))	
    self.sotoTeamEventProxy:addEventListener(remote.sotoTeam.EVENT_SOTO_TEAM_UPDATE, handler(self, self._onRefresh))

	self:updateInfo()
end

function QUIDialogSotoTeam:viewWillDisappear()
    QUIDialogSotoTeam.super.viewWillDisappear(self)
	self:removeBackEvent()

	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)
	
	self.sotoTeamEventProxy:removeAllEventListeners()
    self._touchLayer:removeAllEventListeners()
    self._touchLayer:disable()
    self._touchLayer:detach()

	if self._moveScheduler ~= nil then
		scheduler.unscheduleGlobal(self._moveScheduler)
		self._moveScheduler = nil
	end
	if self._onEnterFrameHandler ~= nil then
		scheduler.unscheduleGlobal(self._onEnterFrameHandler)
		self._onEnterFrameHandler = nil
	end
	if self._talkSchedulerHandler ~= nil then 
		scheduler.unscheduleGlobal(self._talkSchedulerHandler)
		self._talkSchedulerHandler = nil
	end
end

function QUIDialogSotoTeam:resetAll()
	self._isManualRefresh = false
	self._orginPosY = 0
	self._pageHeight = display.height 	--适配全面屏
	self._radius = display.height*0.6	-- 半径
	self._halfGirth = self._radius*PI 	-- 半周长
	self._playerCells = {}
	self._ccbOwner.node_avatar:removeAllChildren()
	self._isInherit = false 
	self._isEquilibrium = false
	self._isInSeason = false
	self._ccbOwner.tf_defens_force:setString(0)
	self._ccbOwner.tf_count:setString(0)
	self._ccbOwner.sp_record_tips:setVisible(false)
	self._ccbOwner.sp_shop_tips:setVisible(false)
	self._ccbOwner.sp_score_tips:setVisible(false)
	self._ccbOwner.sp_team_tips:setVisible(false)
	self._ccbOwner.node_time:setVisible(false)
end

--赛季奖励为被领取时需要弹脸显示并领取奖励
function QUIDialogSotoTeam:checkSeasonAward()
	local awardInfo = remote.sotoTeam:getSotoTeamSeasonReward()
	if awardInfo and awardInfo.oldRank ~= nil then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSotoTeamSeasonAward", options = {info = awardInfo}})
	else
	end
end


function QUIDialogSotoTeam:exitFromBattleHandler()
	self:updateInfo()

	local fighterResult, rivalId = remote.sotoTeam:getTopRankUpdate()
	if fighterResult and fighterResult.sotoTeamUserInfoResponse then
		remote.sotoTeam:setTopRankUpdate(nil)
		local callback = function()
			local deadAvatar = self:getPlayerByIndex(nil, rivalId)
			if fighterResult.gfEndResponse.isWin and deadAvatar then
				self:enableTouchSwallowTop()
				deadAvatar:showDeadEffect(function()
					self:disableTouchSwallowTop()
					self._isManualRefresh = true
					remote.sotoTeam:sotoTeamWarInfoRequest()
				end)
			else
				self._isManualRefresh = true
				remote.sotoTeam:sotoTeamWarInfoRequest()
			end
		end

		local myInfo = fighterResult.sotoTeamUserInfoResponse.myInfo
		if myInfo.curRank < myInfo.lastRank then
			local token = myInfo.topRankAward or 0
			if myInfo.lastRank > myInfo.topRank and token > 0 then
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogArenaRankTop",
			    	options = {myInfo = myInfo, token = token, callback = callback}})
			else
				callback()
			end
		else
			callback()
		end
	end
end

function QUIDialogSotoTeam:showFunctionDescription()
  	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSotoTeamTutorialDialog"})
end

function QUIDialogSotoTeam:showPlayerMoveAni(callback,_to_top,dur,isUniform)

	local move_dis = 0
	if _to_top then
		move_dis = -self._totalHeight
	end
	local isAni = dur > 0
	self:moveTo(move_dis, isAni, dur, callback, isUniform)

end

--刷新
function QUIDialogSotoTeam:_onRefresh(event)
	if event.name == remote.sotoTeam.EVENT_SOTO_TEAM_UPDATE then
		self:updateInfo()
	elseif event.name == remote.sotoTeam.EVENT_SOTO_TEAM_MY_INFO then
		self:updateMyInfo()
	end
end

--战队刷新
function QUIDialogSotoTeam:updateInfo()
	local inherit = remote.sotoTeam:checkIsInheritSeason()
	self._isInSeason = remote.sotoTeam:checkIsInSeason()
	if self._isInherit ~= inherit then
		self._isInherit = inherit
		self:updateDisplay()
	end

	local inEquilibrium = remote.sotoTeam:checkIsEquilibriumSeason()

	if self._isEquilibrium ~= inEquilibrium then
		self._isEquilibrium = inEquilibrium
		self:updateDisplay()
	end

	self:checkSeasonAward()
	self:updateForceInfo()
	self:updateMyInfo()
	self:updatePlayerInfo()
	self:avatarTalkTime()
end


function QUIDialogSotoTeam:updateMyInfo()
	self._myInfo = remote.sotoTeam:getMyInfo()

	if self._selfAvatar == nil then
		self._selfAvatar = QUIWidgetSotoTeam.new()
		self._selfAvatar:showFloorBg(0)
		self._ccbOwner.node_me:addChild(self._selfAvatar)
    	self._selfAvatar:addEventListener(QUIWidgetSotoTeam.EVENT_BATTLE, handler(self, self._clickEvent))
    	self._selfAvatar:addEventListener(QUIWidgetSotoTeam.EVENT_VISIT, handler(self, self.clickCellHandler))
	end
	local selfInfo = remote.sotoTeam:getMyPlayerInfo()
	self._selfAvatar:setInfo(selfInfo)
	self._selfAvatar:setAvatarScale(-1)
	self._selfAvatar:setHideBg(true)

	local fightCountBuy = self._myInfo.fightCountBuy or 0
	local fightCount = self._myInfo.fightCount or 0
	local leftCount = self._configTotalCount + fightCountBuy - fightCount
	self._ccbOwner.tf_count:setString(leftCount)
	self._ccbOwner.tf_rank:setString(self._myInfo.curRank or 0)

	local refreshCount = self._myInfo.refreshTimes or 0
	if refreshCount >= self._configRefreshFreeCount then
		self._ccbOwner.tf_refresh_cost:setString(self._configRefreshToken)
	else
		self._ccbOwner.tf_refresh_cost:setString("免费")
	end

	self._ccbOwner.sp_record_tips:setVisible(remote.sotoTeam:checkFightRecordTip())
	self._ccbOwner.sp_score_tips:setVisible(remote.sotoTeam:checkScoreRewardRedTips())

	-- SeasonInfo 
	if self._isInherit then
		self._ccbOwner.tf_season_name:setString("云顶之战：传承")
	elseif self._isEquilibrium then
		self._ccbOwner.tf_season_name:setString("云顶之战：均衡")
	else
		self._ccbOwner.tf_season_name:setString("云顶之战：起源")
	end
	local seasoninfo = remote.sotoTeam:getSotoTeamSeasonInfo()
	local startAt = seasoninfo.seasonStartAt or 1574200000000
	local endAt = seasoninfo.seasonEndAt or 1574500000000
	local date_start = q.date("*t", startAt/1000)
	local date_end = q.date("*t", endAt/1000)
	local dateStr = string.format("%s年%s月%s日-%s年%s月%s日", date_start.year, date_start.month, date_start.day, date_end.year, date_end.month, date_end.day)
	self._ccbOwner.tf_last_time:setString(dateStr)

end

function QUIDialogSotoTeam:updateForceInfo()
    local force = remote.teamManager:getBattleForceForAllTeam(remote.teamManager.SOTO_TEAM_DEFEND_TEAM, false)
    local fontInfo = db:getForceColorByForce(force, true)
    local force, unit = q.convertLargerNumber(force)
    self._ccbOwner.tf_defens_force:setString(force..(unit or ""))
	local color = string.split(fontInfo.force_color, ";")
	self._ccbOwner.tf_defens_force:setColor(ccc3(color[1], color[2], color[3]))
	self._ccbOwner.sp_team_tips:setVisible(remote.sotoTeam:checkTeamRedTips())
	local width_ = self._ccbOwner.tf_defens_force:getContentSize().width
	self._ccbOwner.tf_inherit_force:setVisible(false)
	self._ccbOwner.sp_inherit:setVisible(false)

	--继承开启
	if self._isInherit then
		local inherit_force_ = self:calculateInheritForce()
		if inherit_force_ > 0 then
			self._ccbOwner.tf_inherit_force:setVisible(true)
			self._ccbOwner.sp_inherit:setVisible(true)
			local inherit_force_, inherit_force_unit = q.convertLargerNumber(math.floor(inherit_force_))
    		self._ccbOwner.tf_inherit_force:setString("+"..inherit_force_..(inherit_force_unit or ""))
    		width_ =  width_ + 10
			self._ccbOwner.tf_inherit_force:setPositionX( self._ccbOwner.tf_defens_force:getPositionX() + width_ )
    		width_ =  width_ + self._ccbOwner.tf_inherit_force:getContentSize().width
			self._ccbOwner.sp_inherit:setPositionX( self._ccbOwner.tf_defens_force:getPositionX() + width_ + 20)
    		width_ =  width_  + self._ccbOwner.sp_inherit:getContentSize().width

		end
	end

	self._ccbOwner.node_pvp:setPositionX( self._pvpNodePosX + width_)
	self._ccbOwner.node_pvp:setVisible(ENABLE_PVP_FORCE)

	local btn_posX =  self._pvpNodePosX + width_ + 90 
	if btn_posX <= 480 then
		btn_posX = 480
	end
	self._ccbOwner.widget_node_team:setPositionX(btn_posX)

end


function  QUIDialogSotoTeam:calculateInheritForce()
	-- local prop =  {}
	-- local helpTeam1 = remote.teamManager:getActorIdsByKey(remote.teamManager.SOTO_TEAM_DEFEND_TEAM, 1)
	 local scale_value = 0.25
	-- remote.herosUtil:updateAllPropByTeams(prop,helpTeam1,scale_value)
	-- local helpTeam =remote.teamManager:getAlternateIdsByKey(remote.teamManager.SOTO_TEAM_DEFEND_TEAM, 1)-- 替补
	-- local inheritForce = remote.teamManager:getAddBuffTeamForce(helpTeam,prop,"InheritForceProp")
	-- return 	inheritForce
	local helpTeam1 = remote.teamManager:getActorIdsByKey(remote.teamManager.SOTO_TEAM_DEFEND_TEAM, 1)
	local helpTeam = #remote.teamManager:getAlternateIdsByKey(remote.teamManager.SOTO_TEAM_DEFEND_TEAM, 1)-- 替补
	local force = 0
	for _,acotrId in pairs(helpTeam1) do
		local heroModel = remote.herosUtil:createHeroPropById(acotrId)
		force = force + heroModel:getLocalBattleForce() 
	
	end	
	return force * helpTeam * scale_value
end

function QUIDialogSotoTeam:updateDisplay()
	local path = QResPath("soto_map")[1]
	local act_path = QResPath("soto_ani")[1]
	if self._isInherit then
		path = QResPath("soto_map")[2]
		act_path = QResPath("soto_ani")[2]
	elseif self._isEquilibrium then
		path = QResPath("soto_map")[3]
		act_path = QResPath("soto_ani")[2]		
	end


	local mapFrame = QSpriteFrameByPath(path)
	self._ccbOwner.sp_map:setDisplayFrame(mapFrame)
	self._ccbOwner.sp_map:setScale(1.25)


	local fcaAnimation = QUIWidgetFcaAnimation.new(act_path, "res")
    self._ccbOwner.node_effect_change:removeAllChildren()
    self._ccbOwner.node_effect_change:addChild(fcaAnimation)
    fcaAnimation:playAnimation("animation", true)
end

function QUIDialogSotoTeam:updatePlayerInfo()
	self._cellWidth = 220
	self._cellHeight = 220
	local index = 1
	local worshipFighters = remote.sotoTeam:getWorshipFighters() or {}
	local rivalFighters = remote.sotoTeam:getRivalFighters()
	for _, value in pairs(worshipFighters) do
		if not self._playerCells[index] then
			local userCell = QUIWidgetSotoTeam.new()
			userCell:addEventListener(userCell.EVENT_BATTLE, handler(self, self.startBattleHandler))
			userCell:addEventListener(userCell.EVENT_VISIT, handler(self, self.clickCellHandler))
    		userCell:addEventListener(userCell.EVENT_WORSHIP, handler(self, self.worshipHandler))
			self._ccbOwner.node_avatar:addChild(userCell)
			self._playerCells[index] = userCell
		end
		self._playerCells[index]:setInfo(value)
		self._playerCells[index]:setIsWorship(true)
		if index == 1 then
			self._playerCells[index]:setCascadeOpacity()
		end
		index = index + 1
	end

	for _, value in pairs(rivalFighters) do
		if not self._playerCells[index] then
			local userCell = QUIWidgetSotoTeam.new()
			userCell:addEventListener(userCell.EVENT_BATTLE, handler(self, self.startBattleHandler))
			userCell:addEventListener(userCell.EVENT_VISIT, handler(self, self.clickCellHandler))
			userCell:addEventListener(userCell.EVENT_QUICK_BATTLE, handler(self, self.quickBattleHandler))
			self._ccbOwner.node_avatar:addChild(userCell)
			self._playerCells[index] = userCell
		end
		self._playerCells[index]:setInfo(value, self._isManualRefresh)
		self._playerCells[index]:setIsWorship(false)
		index = index + 1
	end

	if not self._playerCells[index] then
		local userCell = QUIWidgetSotoTeam.new()
		self._ccbOwner.node_avatar:addChild(userCell)
		self._playerCells[index] = userCell
		self._playerCells[index]:showFloorBg(5)
	end



	self._isManualRefresh = false
	self._totalHeight = (index-3)*self._cellHeight+40
	self._mapHeight = (self._ccbOwner.sp_map:getContentSize().height*1.25 - display.height)/2
  	self._normY = 0
	



	if self:getOptions().defaultPos then
		self:moveTo(self:getOptions().defaultPos, false)
  	 	self._normY = self._ccbOwner.node_norm:getPositionY()
	else
		self:renderFrame()
	end
end

function QUIDialogSotoTeam:getPlayerByIndex(index, userId)
	if index then
		return self._playerCells[index]
	end
	for index, playerCell in ipairs(self._playerCells) do
		if userId == playerCell:getUserId() and playerCell:isVisible() then
			return playerCell
		end
	end
	return nil
end

function QUIDialogSotoTeam:getPlayerCellCurInfo(index, normPosY)
	-- 点高度，即弧长
	local arcLength = index*self._cellHeight+normPosY
	-- arcTemp
	local arcTemp = q.getNumByBoundary(arcLength/self._halfGirth, 0, 1)
	-- 弧度
	local radian = arcTemp*PI
	local scale = (1-arcTemp)
	local cellWidth = (index%2)==0 and self._cellWidth or -self._cellWidth
	local posX = 0
	local posY = 0
	if arcLength >= 0 then
		posY = math.sin(radian)*self._radius
		posX = -scale*cellWidth
	else
		posY = arcLength
		posX = -(self._halfGirth-arcLength)/self._halfGirth*cellWidth
	end
	return posX, posY, scale
end

function QUIDialogSotoTeam:renderFrame()
	local normPosY = self._ccbOwner.node_norm:getPositionY()
	self:getOptions().defaultPos = normPosY

	local totalCount = #self._playerCells
	for index, playerCell in ipairs(self._playerCells) do
		local posX, posY, scale = self:getPlayerCellCurInfo(totalCount-index, normPosY)
		if index == 1 then
			playerCell:setScale(scale*1.4)
			playerCell:setPosition(ccp(-95, posY))

			local opacity = 255
			local absPosX = math.abs(posX)
			if (absPosX - 50) <= MISS_WIDTH then
				opacity = math.floor((absPosX - 50)/MISS_WIDTH*255)
			end
			playerCell:setOpacity(opacity)
			playerCell:setVisible(opacity >= 0)
		else
			playerCell:setScale(scale*1.2)
			playerCell:setPosition(ccp(posX-150, posY))
			playerCell:setVisible(math.abs(posX) >= MISS_WIDTH)
		end
		posY = q.getNumByBoundary(posY, 0, self._radius)
		local scaleY = 1-0.2*posY/self._radius
		playerCell:setBgScaleY(scaleY)
	end

	local mapPosY = self._mapHeight + normPosY/self._totalHeight*self._mapHeight
	self._ccbOwner.sp_map:setPositionY(-mapPosY)
	self._ccbOwner.node_bg_effect:setPositionY(-mapPosY)
end

function QUIDialogSotoTeam:onEnterFrame()
	self:exitEnterFrame()
	self._onEnterFrameHandler = scheduler.scheduleGlobal(handler(self, self.renderFrame), 0)
end

function QUIDialogSotoTeam:exitEnterFrame()
	if self._onEnterFrameHandler ~= nil then
		scheduler.unscheduleGlobal(self._onEnterFrameHandler)
		self._onEnterFrameHandler = nil
	end
end

function QUIDialogSotoTeam:contentRunAction(posY, delayTime, callback, isUniform)
	self:onEnterFrame()
	if delayTime == nil then delayTime = 0.5 end
    local actionArrayIn = CCArray:create()
    local curveMove = CCMoveTo:create(delayTime, ccp(0, posY))
    local speed
    if isUniform then
    	speed = curveMove
    else
		speed = CCEaseExponentialOut:create(curveMove)
	end
	actionArrayIn:addObject(speed)
    actionArrayIn:addObject(CCCallFunc:create(function () 
			self:exitEnterFrame()
			self:renderFrame()
			if callback then
				callback()
			end
        end))
    local ccsequence = CCSequence:create(actionArrayIn)
	self._ccbOwner.node_norm:stopAllActions()		
    self._ccbOwner.node_norm:runAction(ccsequence)
end

function QUIDialogSotoTeam:moveTo(posY, isAnimation, delayTime, callback, isUniform)
	local targetY = self._normY + posY
	if targetY < - self._totalHeight then
		targetY = - self._totalHeight
	elseif targetY > self._orginPosY then
		targetY = self._orginPosY
	end
	if isAnimation then
		self:contentRunAction(targetY, delayTime, callback, isUniform)
	else
		self._ccbOwner.node_norm:setPositionY(targetY)
		self:renderFrame()
	end
end

function QUIDialogSotoTeam:onTouchEvent(event)
	if event == nil or event.name == nil then
        return
    end
	if event.name == QUIGestureRecognizer.EVENT_SLIDE_GESTURE then
    	if self._startY == nil or self._normY == nil then
    		return
    	end
    	local posY = event.distance.y
    	if math.abs(posY) ~= 0 then
			self:moveTo(posY, true)
		end
  	elseif event.name == "began" then
  		self._startY = event.y
  	 	self._normY = self._ccbOwner.node_norm:getPositionY()
    elseif event.name == "moved" then
    	if self._startY == nil or self._normY == nil then
    		return
    	end
        if math.abs(event.y - self._startY) > 10 then
            self._isMove = true
        end
    	local offsetY = event.y - self._startY
		self:moveTo(offsetY, false)
	elseif event.name == "ended" then
    	self._moveScheduler = self:getScheduler().performWithDelayGlobal(function ()
			self._isMove = false
		end, 0)
    end
end

----------------------处理avatar气泡部分-------------------
function QUIDialogSotoTeam:avatarTalkTime()
	if self._talkSchedulerHandler ~= nil then 
		scheduler.unscheduleGlobal(self._talkSchedulerHandler)
		self._talkSchedulerHandler = nil
	end
	local totalCount = #self._playerCells
	if totalCount <= 0 then return end
	local count = math.random(1, totalCount)

	for index, widget in pairs(self._playerCells) do
		widget:removeWord()
		if count == index then
			widget:showWord()
		end
	end
	self._talkSchedulerHandler = scheduler.performWithDelayGlobal(handler(self, self.avatarTalkTime), 5)
end

-----------------------------------------------------------
function QUIDialogSotoTeam:startBattle(info, index)
	local rivalInfo = info
	if rivalInfo == nil then
		return 
	end
    if not self._isInSeason and not app.tutorial:isInTutorial()  then --引导时放行 不判断赛季
		app.tip:floatTip("魂师大人，本赛季云顶之战已经结束，期待您下赛季的表现～")
    	return 
    end

	local rivalsPos = rivalInfo.rank
	local myInfo = self._myInfo
	
	local battleFunc = function ()
		remote.sotoTeam:sotoTeamQueryFighterRequest(rivalInfo.userId, function(data)
			local rivalsFight = (data.towerFightersDetail or {})[1]
			local sotoTeamArrangement = QSotoTeamArrangement.new({myInfo = myInfo, rivalInfo = rivalsFight, rivalsPos = rivalsPos, teamKey = remote.teamManager.SOTO_TEAM_ATTACK_TEAM})
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogAlternateTeamArrangement",
				options = {arrangement = sotoTeamArrangement}})
		end)
	end

	remote.sotoTeam:sotoTeamFightStartCheckRequest(remote.user.userId, myInfo.curRank, rivalInfo.userId, rivalsPos, function(data)
			local response = data.sotoTeamUserInfoResponse
			if self:safeCheck() and response and response.startCheck then
				if response.startCheck.isRivalPosChanged or response.startCheck.isSelfPosChanged then
					app:alert({content = "排名发生了变化，确认刷新后重新开始挑战", callback = function (state)
						if state == ALERT_TYPE.CONFIRM then
							self._isManualRefresh = true
							remote.sotoTeam:sotoTeamWarInfoRequest()
						end
					end})
				else
					if battleFunc then
						battleFunc()
					end
				end
			end
		end, function()
			if battleFunc then
				battleFunc()
			end
		end)
end

function QUIDialogSotoTeam:autoBattle(info)
	local rivalInfo = info
	if rivalInfo == nil then
		return 
	end
    if not self._isInSeason and not app.tutorial:isInTutorial()  then --引导时放行 不判断赛季
		app.tip:floatTip("魂师大人，本赛季云顶之战已经结束，期待您下赛季的表现～")
    	return 
    end

	local rivalsPos = rivalInfo.rank
	local myInfo = self._myInfo

	local success = function(data)
		if self:safeCheck() then
			self.rivalId = nil
			local batchAwards = {}
			local awards = {}
			for _,value in pairs(data.prizes or {}) do
	            local typeName = remote.items:getItemType(value.type)
	            table.insert(awards, {typeName = typeName, id = value.id, count = value.count})
			end
			if data.gfEndResponse.isWin then
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogWin", 
                    options = {awards = awards, callback = function()
			    		if self:safeCheck() then
			    			self:exitFromBattleHandler()
						end
                    end}}, {isPopCurrentDialog = true})
			else
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogLose", 
					options = {awards = awards, callback = function()
			    		if self:safeCheck() then
			    			self:exitFromBattleHandler()
						end
		            end}}, {isPopCurrentDialog = true})
			end
		end
	end
	local failed = function()
		remote.sotoTeam:sotoTeamWarInfoRequest()
	end

	local battleFunc = function ()
		remote.sotoTeam:sotoTeamQueryFighterRequest(rivalInfo.userId, function(data)
			local rivalsFight = (data.towerFightersDetail or {})[1]
			local teams = remote.teamManager:getTeamByKey(remote.teamManager.SOTO_TEAM_ATTACK_TEAM)
			local heroIdList1 = teams:getAllTeam()

			local autoArrangement1 = QSotoTeamArrangement.new({myInfo = myInfo, rivalInfo = rivalsFight, rivalsPos = rivalsPos, teamKey = remote.teamManager.SOTO_TEAM_ATTACK_TEAM})

			-- local heroIdList1 = autoArrangement1:getHeroIdList()

			local callback = function()
				local sotoTeamArrangement = QSotoTeamArrangement.new({myInfo = myInfo, rivalInfo = rivalsFight, rivalsPos = rivalsPos, teamKey = remote.teamManager.SOTO_TEAM_ATTACK_TEAM})
				app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogAlternateTeamArrangement",
					options = {arrangement = sotoTeamArrangement}})
			end
			if not autoArrangement1:teamValidity(heroIdList1[1].actorIds, 1, callback) then 
				return
			end

			local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.SOTO_TEAM_ATTACK_TEAM, false)
			local soulMaxNum = teamVO:getSpiritsMaxCountByIndex(1)
			local numSpiritInOne = heroIdList1[1].spiritIds == nil and 0 or #heroIdList1[1].spiritIds
		    if soulMaxNum > 0 
		    	and ((heroIdList1[1].spiritIds ~= nil and #heroIdList1[1].spiritIds < soulMaxNum)) 
		    	and (#remote.soulSpirit:getMySoulSpiritInfoList() - numSpiritInOne) > 0 then
		        app:alert({content="有主力魂灵未上阵，确定开始战斗吗？",title="系统提示", callback = function (state)
		            if state == ALERT_TYPE.CONFIRM then
						autoArrangement1:startAutoFight(heroIdList1,success,failed)
		            end
		        end})
		    else
		    	autoArrangement1:startAutoFight(heroIdList1,success,failed)
		    end
		end)
	end

	remote.sotoTeam:sotoTeamFightStartCheckRequest(remote.user.userId, myInfo.curRank, rivalInfo.userId, rivalsPos, function(data)
			local response = data.sotoTeamUserInfoResponse
			if self:safeCheck() and response and response.startCheck then
				if response.startCheck.isRivalPosChanged or response.startCheck.isSelfPosChanged then
					app:alert({content = "排名发生了变化，确认刷新后重新开始挑战", callback = function (state)
						if state == ALERT_TYPE.CONFIRM then
							self._isManualRefresh = true
							remote.sotoTeam:sotoTeamWarInfoRequest()
						end
					end})
				else
					if battleFunc then
						battleFunc()
					end
				end
			end
		end, function(data)
			if battleFunc then
				battleFunc()
			end
		end)

end

function QUIDialogSotoTeam:quickBattle(info)
	if info == nil then
		return 
	end
	local oldScore = self._myInfo.integral
	remote.sotoTeam:sotoTeamQuickFightRequest(info.userId, info.rank, function (data)
   		app.taskEvent:updateTaskEventProgress(app.taskEvent.SOTO_TEAM_TASK_EVENT, 1, false, true)
		remote.user:addPropNumForKey("todaySotoTeamFightCount")
		
		local response = data.sotoTeamUserInfoResponse
		if self:safeCheck() and response then
			local batchAwards = {}
			local awards = data.prizes or {}
	        for _, value in pairs(data.extraExpItem or {}) do
	            table.insert(awards, value)
	        end
			table.insert(batchAwards, {awards = awards})
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnityFastBattle", 
				options = {fast_type = FAST_FIGHT_TYPE.RANK_FAST,awards = batchAwards, yield = response.yield, userComeBackRatio = data.userComeBackRatio, score = response.myInfo.integral - oldScore, name = "云顶之战扫荡", callback = function ()
		    		if self:safeCheck() then
		    			self._isManualRefresh = true
						self:updateInfo()
					end
				end}},{isPopCurrentDialog = false})
		end
	end)
end

function QUIDialogSotoTeam:worshipHandler(event)
    app.sound:playSound("common_small")

    local nowTime = q.serverTime() 
    local nowDateTable = q.date("*t", nowTime)
	if ( nowDateTable.hour == 21 and nowDateTable.min < 16 ) then
		app.tip:floatTip("魂师大人，21：00～21：15是每日结算时间，无法膜拜，稍后再来吧～")
		return
	end

	local pos = event.info.rank
	if remote.sotoTeam:checkTodayWorshipByPos(pos) then
        app.tip:floatTip("今日已经膜拜过了") 
    else
    	local widget = self:getPlayerByIndex(nil, event.info.userId)
		remote.sotoTeam:sotoTeamWorshipRequest(event.info.userId, pos, function (data)
			local prize = data.prizes[1]
			local yield = data.sotoTeamUserInfoResponse.yield
            app.taskEvent:updateTaskEventProgress(app.taskEvent.SOTO_TEAM_WORSHIP_EVENT, 1, false, true)
			if self:safeCheck() and prize then
				widget:showFans(function()
					self:updatePlayerInfo()
				end)
				if self._worshipAnimationPlayer ~= nil then
					self._worshipAnimationPlayer:disappear()
					self:getView():removeChild(self._worshipAnimationPlayer)
					self._worshipAnimationPlayer = nil
				end
				self._worshipAnimationPlayer = QUIWidgetAnimationPlayer.new()

				local wallet = remote.items:getWalletByType(prize.type)
				if yield > 1 then
					self._worshipAnimationPlayer:playAnimation("ccb/effects/Baoji_mobai.ccbi", function (ccbOwner)
						ccbOwner.tf_money:setString(prize.count)
						ccbOwner.tf_2:setString(wallet.nativeName)
						ccbOwner.tf_2:setPositionX(ccbOwner.tf_money:getPositionX() + ccbOwner.tf_money:getContentSize().width/2 + 10)
						if yield > 2 then
							ccbOwner.sp_title1:setVisible(false)
						else
							ccbOwner.sp_title2:setVisible(false)
						end
					end)
				else
					self._worshipAnimationPlayer:playAnimation("ccb/effects/team_arena.ccbi", function (ccbOwner)
						ccbOwner.tf_money:setString(prize.count)
						ccbOwner.tf_2:setString(wallet.nativeName)
					end)
				end
				self:getView():addChild(self._worshipAnimationPlayer)
			end
		end)
	end
end

function QUIDialogSotoTeam:clickCellHandler(event)
	if self._isMove then return end
    app.sound:playSound("common_small")

    local userId = event.info.userId
	remote.sotoTeam:sotoTeamQueryFighterRequest(userId, function(data)
		local rivalInfo = (data.towerFightersDetail or {})[1] 
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
    		options = {fighter = rivalInfo, forceTitle1 = "防守战力：", model = GAME_MODEL.NORMAL, isPVP = true, isEquilibrium = self._isEquilibrium}}, {isPopCurrentDialog = false})
	end)
end

function QUIDialogSotoTeam:checkCanBattle(event, startHandler)
	if event.info.userId == remote.user.userId then
		app.tip:floatTip("不能挑战自己！")
		return false
	end
	if event.info.rank <= 5 and self._myInfo.curRank > 20 then
		app.tip:floatTip("太不自量力了，先冲到前20名再来挑战我吧！")
        return false
	end

    if not self._isInSeason then
		app.tip:floatTip("魂师大人，本赛季云顶之战已经结束，期待您下赛季的表现～")
    	return false
    end	
	local buyCount = self._myInfo.fightCountBuy or 0
	local fightCount = self._myInfo.fightCount or 0
	if self._configTotalCount + buyCount - fightCount <= 0 then
    	self:_onTriggerPlus()
		return false
	end

	return true
end

function QUIDialogSotoTeam:quickBattleHandler(event)
	if self._isMove then return  end
    app.sound:playSound("common_small")

    if self:checkCanBattle(event) then
    	if event.isFastFight then
			self:quickBattle(event.info)
		else
			self:autoBattle(event.info)
		end
	end
end

function QUIDialogSotoTeam:startBattleHandler(event)
	if self._isMove then return  end
    app.sound:playSound("common_small")
	if self:checkCanBattle(event) then
		self:startBattle(event.info)
	end
end

function QUIDialogSotoTeam:_clickEvent(event)
	self:_onTriggerTeam()
end

function QUIDialogSotoTeam:_onTriggerHelp(event)
    app.sound:playSound("common_small")
  	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSotoTeamHelp",
    	options = {info = self.myInfo}})
end


function QUIDialogSotoTeam:_onTriggerSeasonTips(event)
    app.sound:playSound("common_small")
    if q.buttonEventShadow(event, self._ccbOwner.btn_season_tips) == false then return end

    local dur_ = q.flashFrameTransferDur(11)

	self._ccbOwner.mySeasonInfo:stopAllActions()
	self._ccbOwner.tf_season_name:setOpacityModifyRGB(true)

	makeNodeFadeToByTimeAndOpacity(self._ccbOwner.mySeasonInfo,dur_,0)
   local exit_callback = function() 
		makeNodeFadeToByTimeAndOpacity(self._ccbOwner.mySeasonInfo,dur_,255)
	end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSotoTeamIntroDialog", options = {callback = exit_callback}}, {isPopCurrentDialog = false})
end

function QUIDialogSotoTeam:_onTriggerRecord(event)
    app.sound:playSound("common_small")
	remote.sotoTeam:setSotoTeamRecordTip(false)
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogAgainstRecord", 
		options = {reportType = REPORT_TYPE.SOTO_TEAM}}, {isPopCurrentDialog = false})
end

function QUIDialogSotoTeam:_onTriggerRank(event)
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRank", 
		options = {initRank = "sotoTeam"}}, {isPopCurrentDialog = false})
end

function QUIDialogSotoTeam:_onTriggerShop(event)
    app.sound:playSound("common_small")
  	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSotoTeamStore", 
  		options = {type = SHOP_ID.sotoTeamShop, info = {arenaMoney = remote.user.arenaMoney or 0}}})
end

function QUIDialogSotoTeam:_onTriggerScore()
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSotoTeamScore"})
	
end

function QUIDialogSotoTeam:_onTriggerTeam(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_team) == false then return end
	if event ~= nil then
    	app.sound:playSound("common_small")
    end
  --   if not self._isInSeason then 
		-- app.tip:floatTip("魂师大人，本赛季云顶之战已经结束，期待您下赛季的表现～")
  --   	return 
  --   end

	local sotoTeamDefenseArrangement = QSotoTeamDefenseArrangement.new({})
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAlternateTeamArrangement",
		options = {arrangement = sotoTeamDefenseArrangement}})
end

function QUIDialogSotoTeam:_onTriggerPlus(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_plus) == false then return end
	if event ~= nil then
    	app.sound:playSound("common_small")
    end
	if (self._myInfo.fightCountBuy or 0) >= QVIPUtil:getSotoTeamResetCount() then
		app:vipAlert({title = "云顶之战可购买挑战次数", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.SOTO_TEAM_RESET_COUNT}, false)
	else
		if self._isInSeason then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCountBase",
				options = {cls = "QBuyCountSotoTeam"}})
		else
			app.tip:floatTip("本赛季云顶之战已经结束，无法购买挑战次数")
		end
	end
end

function QUIDialogSotoTeam:_onTriggerClickPVP(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_pvp) == false then return end
    app.sound:playSound("common_small")

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPVPPropTip", 
        options = {teamKey = remote.teamManager.SOTO_TEAM_DEFEND_TEAM, isEquilibrium = self._isEquilibrium}}, {isPopCurrentDialog = false})
end

function QUIDialogSotoTeam:_onTriggerRefresh(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_refresh) == false then return end
    app.sound:playSound("common_small")
	local refreshCount = self._myInfo.refreshTimes or 0
	-- if refreshCount >= QVIPUtil:getSotoTeamRefreshCount() then
	-- 	app:vipAlert({title = "斗魂场可刷新次数", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.SOTO_TEAM_REFRESH_COUNT}, false)
	-- else
	if refreshCount >= self._configRefreshFreeCount then
		if self._configRefreshToken > remote.user.token then
			QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY)
		else
			self._isManualRefresh = true
			remote.sotoTeam:sotoTeamRefreshRequest()
		end
	else
		self._isManualRefresh = true
		remote.sotoTeam:sotoTeamRefreshRequest()
	end
end

return QUIDialogSotoTeam