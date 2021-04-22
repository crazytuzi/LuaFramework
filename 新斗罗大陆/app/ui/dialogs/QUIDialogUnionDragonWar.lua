-- 
-- zxs
-- 宗门武魂战
-- 
local QUIDialogBaseUnion = import("..dialogs.QUIDialogBaseUnion")
local QUIDialogUnionDragonWar = class("QUIDialogUnionDragonWar", QUIDialogBaseUnion)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUnionDragonWarArrangement = import("...arrangement.QUnionDragonWarArrangement")
local QVIPUtil = import("...utils.QVIPUtil")
local QUnionAvatar = import("...utils.QUnionAvatar")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")
local QUIWidgetFloorIcon = import("..widgets.QUIWidgetFloorIcon")
local QUIWidgetAnimationPlayer = import("...ui.widgets.QUIWidgetAnimationPlayer")
local QRichText = import "..utils.QRichText"

function QUIDialogUnionDragonWar:ctor(options)
	local ccbFile = "ccb/Dialog_society_dragontrain_battlemain.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerRule", callback = handler(self, self._onTriggerRule)},
		{ccbCallbackName = "onTriggerGlory", callback = handler(self, self._onTriggerGlory)},
		{ccbCallbackName = "onTriggerRank", callback = handler(self, self._onTriggerRank)},
		{ccbCallbackName = "onTriggerAwards", callback = handler(self, self._onTriggerAwards)},
		{ccbCallbackName = "onTriggerShop", callback = handler(self, self._onTriggerShop)},
		{ccbCallbackName = "onTriggerInfo", callback = handler(self, self._onTriggerInfo)},
		{ccbCallbackName = "onTriggerBuff", callback = handler(self, self._onTriggerBuff)},
		{ccbCallbackName = "onTriggerPlus", callback = handler(self, self._onTriggerPlus)},
		{ccbCallbackName = "onTriggerAttack", callback = handler(self, self._onTriggerAttack)},
		{ccbCallbackName = "onTriggerWinBuffer", callback = handler(self, self._onTriggerWinBuffer)},
		{ccbCallbackName = "onTriggerHolyBuffer", callback = handler(self, self._onTriggerHolyBuffer)},
		{ccbCallbackName = "onTriggerMySkill", callback = handler(self, self._onTriggerMySkill)},
		{ccbCallbackName = "onTriggerEnemySkill", callback = handler(self, self._onTriggerEnemySkill)},
		{ccbCallbackName = "onTriggerShowRank", callback = handler(self, self._onTriggerShowRank)},
		{ccbCallbackName = "onTriggerTopRank", callback = handler(self, self._onTriggerTopRank)},
	}
	QUIDialogUnionDragonWar.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	
	self:setSocietyNameVisible(false)

	self._freeFightCount = db:getConfiguration()["sociaty_dragon_fight_initial"].value
	self._myDragonAvatar = nil
	self._enemyDragonAvatar = nil
	self._hurtScheduler = nil
	self._showRank = app:getUserOperateRecord():getDragonWarRankStated() or true
	self._isShowHurt = false
	self._hurtList = {}

	self._enemyBloodScaleX = self._ccbOwner.sp_enemy_blood_bar:getScaleX()
	self._myBloodScaleX = self._ccbOwner.sp_my_blood_bar:getScaleX()
end

function QUIDialogUnionDragonWar:setSocietyTopBar(page)
	if page and page.topBar then
		page.topBar:showWithStyle({TOP_BAR_TYPE.DRAGON_WAR_MONEY, TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.BATTLE_FORCE})
	end
end

function QUIDialogUnionDragonWar:viewDidAppear()
	QUIDialogUnionDragonWar.super.viewDidAppear(self)
	self:addBackEvent(false)

	self._dragonWarEventProxy = cc.EventProxy.new(remote.unionDragonWar)
  	self._dragonWarEventProxy:addEventListener(remote.unionDragonWar.EVENT_UPDATE_FIGHT_COUNT, handler(self,self.buyFightCountSuccess))
  	self._dragonWarEventProxy:addEventListener(remote.unionDragonWar.EVENT_UPDATE_DRANGON_INFO, handler(self,self.updateInfo))
  	self._dragonWarEventProxy:addEventListener(remote.unionDragonWar.EVENT_UPDATE_MYINFO, handler(self,self.checkRedTips))
   	self._dragonWarEventProxy:addEventListener(remote.unionDragonWar.EVENT_UPDATE_AWARD, handler(self, self.checkScoreReward))
    self._dragonWarEventProxy:addEventListener(remote.unionDragonWar.EVENT_UPDATE_KILL_INFO, handler(self, self.setBossHurtInfo))

	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)

	self:updateInfo()

	self:checkBuffTip()

	self:setRankShowStated(false)
end

function QUIDialogUnionDragonWar:viewWillDisappear()
	QUIDialogUnionDragonWar.super.viewWillDisappear(self)
	self:removeBackEvent()

    if self._countDownScheduler ~= nil then
        scheduler.unscheduleGlobal(self._countDownScheduler)
        self._countDownScheduler = nil
    end
    if self._holyBufferScheduler ~= nil then
    	scheduler.unscheduleGlobal(self._holyBufferScheduler)
    	self._holyBufferScheduler = nil
    end
    if self._seasonScheduler ~= nil then
    	scheduler.unscheduleGlobal(self._seasonScheduler)
    	self._seasonScheduler = nil
    end
	if self._hurtScheduler ~= nil then
    	scheduler.unscheduleGlobal(self._hurtScheduler)
    	self._hurtScheduler = nil
    end

    self._dragonWarEventProxy:removeAllEventListeners()

	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)
end

function QUIDialogUnionDragonWar:buyFightCountSuccess()
	self:setFighterCount()
end

function QUIDialogUnionDragonWar:exitFromBattleHandler()
	self:updateInfo()
end

function QUIDialogUnionDragonWar:updateInfo()

	if remote.union:checkHaveUnion() == false then
		local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
		if page and page._onTriggerHome then
			page:_onTriggerHome()
		end
		return
	end

	self:setMyInfo()

	self:setFighterCount()

	self:checkDragonWarIsOpen()

	self:setTopRanks()

	self:checkRedTips()

	self:checkWeather()
end

function QUIDialogUnionDragonWar:setMyInfo()
	self._myInfo = remote.unionDragonWar:getMyInfo()
	self._myFighterInfo = remote.unionDragonWar:getMyDragonFighterInfo()
	self._enemyFighterInfo = remote.unionDragonWar:getEnemyDragonFighterInfo()

	-- 设置中间血量和伤害值，用于显示玩家伤害后血量变化
	self._tempCurMyDragonHp = self._myFighterInfo.dragonCurrHp or 0
	self._tempCurMyDragonFullHurt = self._myFighterInfo.dragonHurtHp or 0
	self._tempCurEnemyDragonHp = self._enemyFighterInfo.dragonCurrHp or 0
	self._tempCurEnemyDragonFullHurt = self._enemyFighterInfo.dragonHurtHp or 0

	-- set union icon and score
	if self._unionAvatar == nil then
		local icon = remote.union.consortia.icon
		self._unionAvatar = QUnionAvatar.new(icon)
		self._ccbOwner.node_icon:addChild(self._unionAvatar)
		self._ccbOwner.node_icon:setScale(0.6)
	end
	self._unionAvatar:setConsortiaWarFloor(remote.union.consortia.consortiaWarFloor)

	local floor = self._myFighterInfo.floor or 1
	local curfloorInfo = db:getUnionDragonFloorInfoByFloor(floor)
	local nextfloorInfo = db:getUnionDragonFloorInfoByFloor(floor+1)
	self._ccbOwner.tf_union_rank:setString(curfloorInfo.name or "")

	local standard = nextfloorInfo.score_standard or 0
	if standard == 0 then
		self._ccbOwner.tf_user_score:setString(self._myFighterInfo.score or 0)
	else
		self._ccbOwner.tf_user_score:setString((self._myFighterInfo.score or 0).."/"..standard)
	end
	
	-- 段位icon
	if self._floorIcon == nil then
		self._floorIcon = QUIWidgetFloorIcon.new({isLarge = true})
		self._ccbOwner.node_floor:removeAllChildren()
		self._ccbOwner.node_floor:setScale(0.33)
 		self._ccbOwner.node_floor:addChild(self._floorIcon)
 	end
	self._floorIcon:setInfo(floor, "unionDragonWar")
	self._floorIcon:setShowName(false)

	-- set my buffer time
	local isShowBuff, endAt = remote.unionDragonWar:checkMyHolyBuffer()
	self._ccbOwner.node_holy_buffer:setVisible(isShowBuff)
	if isShowBuff and endAt > 0 then
		self._holyBufferScheduler = scheduler.performWithDelayGlobal(function ()
			if self:safeCheck() then
				self:setMyInfo()
			end
		end, endAt)
	end

	-- 连战加成
	local myStreakWin = self._myFighterInfo.streakWin or 0
	self._ccbOwner.node_win_buffer:setVisible(myStreakWin > 1)  
	if myStreakWin > 5 then
		myStreakWin = 5
	end
	local iconPath = QResPath("dragon_war_win_buffer")[myStreakWin]
	if iconPath ~= nil then
    	local iconFrame = QSpriteFrameByPath(iconPath)
    	self._ccbOwner.sp_win_buffer:setDisplayFrame(iconFrame)
	end

	self:setSeasonInfo()
end

function QUIDialogUnionDragonWar:setFighterCount()
	local myInfo = remote.unionDragonWar:getMyInfo()
    local buyCount = myInfo.buyFightCount or 0
	self._count = self._freeFightCount + buyCount - (myInfo.fightCount or 0)
	self._ccbOwner.tf_attack_count:setString(self._count)

    local totalVIPNum = QVIPUtil:getCountByWordField("sociaty_dragon_fight_times", QVIPUtil:getMaxLevel())
    local totalNum = QVIPUtil:getCountByWordField("sociaty_dragon_fight_times")

    self._ccbOwner.node_btn_plus:setVisible(totalVIPNum > totalNum or totalNum > buyCount)
    self._ccbOwner.node_attack_tip:setVisible(self._count > 0)
end

function QUIDialogUnionDragonWar:setSeasonInfo()
	local seasonInfo = remote.unionDragonWar:getCurrentSeasonInfo()
	local endAt = (seasonInfo.seasonEndAt or 0)/1000
	self._ccbOwner.node_season_time:setVisible(true)

	local countDownFunc
	countDownFunc = function() 
		if self._seasonScheduler ~= nil then
            scheduler.unscheduleGlobal(self._seasonScheduler)
            self._seasonScheduler = nil
        end
		local offsetTime = endAt - q.serverTime()
		if offsetTime > 0 then
			local time = q.timeToDayHourMinute(offsetTime)
			self._ccbOwner.tf_season_time:setString(time)
            self._seasonScheduler = scheduler.scheduleGlobal(countDownFunc, 1)
        else
        	self._ccbOwner.node_season_time:setVisible(false)
		end
	end
	countDownFunc()
end

function QUIDialogUnionDragonWar:checkDragonWarIsOpen()
	self._ccbOwner.node_bottom:setVisible(true)
	self._ccbOwner.node_count_down:setPositionX(-424)
	self._ccbOwner.tf_count_down_content:setString("后造成总伤害百分比更多的宗门获胜")

	local isOpen, opentTime, closeTime = remote.unionDragonWar:checkDragonWarOpen()
	if isOpen then
		self:setCountDownForDragonWar(closeTime)
	else
		self:setCountDownForDragonWar(opentTime)
		self._ccbOwner.node_bottom:setVisible(false)
		self._ccbOwner.node_count_down:setPositionX(-60)
		self._ccbOwner.tf_count_down_content:setString("后匹配新的宗门进行下一轮战斗")
	end
	
	self:checkScoreReward()
	
	self:setFighterUnionInfo()

	self:updateDragonHpInfo(isOpen)
end

function QUIDialogUnionDragonWar:setCountDownForDragonWar(unlockTime)
    local schedulerFunc
    schedulerFunc = function()
        if self._countDownScheduler ~= nil then
            scheduler.unscheduleGlobal(self._countDownScheduler)
            self._countDownScheduler = nil
        end
        local nowTime = q.serverTime()
        if unlockTime >= nowTime then
            self._ccbOwner.tf_count_down:setString(q.timeToHourMinuteSecond(unlockTime-nowTime))
            self._countDownScheduler = scheduler.scheduleGlobal(schedulerFunc, 1)
        else
            remote.unionDragonWar:dragonWarGetMyInfoRequest(function()
				remote.unionDragonWar:dragonWarGetCurrentBattleInfoRequest(function()
					remote.unionDragonWar:dragonWarGetDailyRewardListRequest(function()
						if self:safeCheck() then
                    		self:updateInfo()
                    	end
					end)
				end)
            end)
        end
    end
    schedulerFunc()
end

function QUIDialogUnionDragonWar:setFighterUnionInfo()
    self._ccbOwner.sp_my_win:setVisible(false)
    self._ccbOwner.sp_my_lose:setVisible(false)
    self._ccbOwner.sp_enemy_win:setVisible(false)
    self._ccbOwner.sp_enemy_lose:setVisible(false)

	-- set dragon avatar
	local myDragonConfig = db:getUnionDragonConfigById(self._myFighterInfo.dragonId)
	if self._myDragonAvatar == nil then
		self._myDragonAvatar = QUIWidgetFcaAnimation.new(myDragonConfig.fca, "actor", {backSoulShowEffect = myDragonConfig.effect})
        self._myDragonAvatar:setScaleX(-global.dragon_spine_scale)
        self._myDragonAvatar:setScaleY(global.dragon_spine_scale)
	    self._myDragonAvatar:setPositionY(global.dragon_spine_offsetY)
		local scaleX = self._ccbOwner.node_my_avatar:getScaleX()
		self._ccbOwner.node_my_avatar:setScaleX(scaleX)
		self._ccbOwner.node_my_avatar:addChild(self._myDragonAvatar)
	end
	local color, dragonFloor = remote.dragon:getDragonColor(self._myFighterInfo.dragonId, self._myFighterInfo.dragonLevel)
    self._ccbOwner.tf_my_dragon_name:setColor(color)
    self._ccbOwner.tf_my_dragon_floor:setColor(color)
    setShadowByFontColor(self._ccbOwner.tf_my_dragon_name, color)
    setShadowByFontColor(self._ccbOwner.tf_my_dragon_floor, color)
	self._ccbOwner.tf_my_dragon_level:setString("lv."..self._myFighterInfo.dragonLevel)
	self._ccbOwner.tf_my_dragon_name:setString(myDragonConfig.dragon_name or "")
	self._ccbOwner.tf_my_union_name:setString(self._myFighterInfo.consortiaName or "")
	self._ccbOwner.tf_my_env_name:setString(self._myFighterInfo.gameAreaName or "")
	self._ccbOwner.tf_my_dragon_floor:setString(remote.dragon.DRAGON_FLOOR[dragonFloor].."阶")

	-- 段位icon
	if self._myFloor == nil then
		self._myFloor = QUIWidgetFloorIcon.new({isLarge = true})
		self._ccbOwner.node_my_floor:removeAllChildren()
 		self._ccbOwner.node_my_floor:addChild(self._myFloor)
 	end
	self._myFloor:setInfo(self._myFighterInfo.floor, "unionDragonWar")
	self._myFloor:setShowName(false)

	local enemyDragonConfig = db:getUnionDragonConfigById(self._enemyFighterInfo.dragonId)
	if self._enemyDragonAvatar == nil then
		self._enemyDragonAvatar = QUIWidgetFcaAnimation.new(enemyDragonConfig.fca, "actor", {backSoulShowEffect = enemyDragonConfig.effect})
        self._enemyDragonAvatar:setScaleX(-global.dragon_spine_scale)
        self._enemyDragonAvatar:setScaleY(global.dragon_spine_scale)
        self._enemyDragonAvatar:setPositionY(global.dragon_spine_offsetY)
	    local scaleX = self._ccbOwner.node_enemy_avatar:getScaleX()
		self._ccbOwner.node_enemy_avatar:setScaleX(-scaleX)
		self._ccbOwner.node_enemy_avatar:addChild(self._enemyDragonAvatar)
	end
	local color, dragonFloor = remote.dragon:getDragonColor(self._enemyFighterInfo.dragonId, self._enemyFighterInfo.dragonLevel)
	self._ccbOwner.tf_enemy_dragon_name:setColor(color)
	self._ccbOwner.tf_enemy_dragon_floor:setColor(color)
    setShadowByFontColor(self._ccbOwner.tf_enemy_dragon_name, color)
    setShadowByFontColor(self._ccbOwner.tf_enemy_dragon_floor, color)
	self._ccbOwner.tf_enemy_dragon_level:setString("lv."..self._enemyFighterInfo.dragonLevel)
	self._ccbOwner.tf_enemy_dragon_name:setString(enemyDragonConfig.dragon_name or "")
	self._ccbOwner.tf_enemy_union_name:setString(self._enemyFighterInfo.consortiaName or "")
	self._ccbOwner.tf_enemy_env_name:setString(self._enemyFighterInfo.gameAreaName or "")
	self._ccbOwner.tf_enemy_dragon_floor:setString(remote.dragon.DRAGON_FLOOR[dragonFloor].."阶")

	-- 段位icon
	if self._enemyFloor == nil then
		self._enemyFloor = QUIWidgetFloorIcon.new({isLarge = true})
		self._ccbOwner.node_enemy_floor:removeAllChildren()
 		self._ccbOwner.node_enemy_floor:addChild(self._enemyFloor)
 	end
	self._enemyFloor:setInfo(self._enemyFighterInfo.floor, "unionDragonWar")
	self._enemyFloor:setShowName(false)
end

function QUIDialogUnionDragonWar:updateDragonHpInfo(isOpen)
	-- myDragonHp
	-- local myDragonHp = self._myFighterInfo.dragonCurrHp or 0
	-- local myDragonFullHurt = self._myFighterInfo.dragonHurtHp or 0
	local myDragonHp = self._tempCurMyDragonHp
	local myDragonFullHurt = self._tempCurMyDragonFullHurt
	local myDragonFullHp = self._myFighterInfo.dragonFullHp or 0
	local myHp, myUint = q.convertLargerNumber(myDragonHp)
	local myFullHp, myFullUint = q.convertLargerNumber(myDragonFullHp)
	local myHpPercent = string.format("%.4f", (myDragonFullHurt/myDragonFullHp or 0))
	if myDragonHp ~= myDragonFullHp and tonumber(myHpPercent) < 0.0001 then
		myHpPercent = 0.0001
	end
	if myDragonHp <= 0 then
		self._ccbOwner.tf_my_blood:setString(string.format("(受到总伤害：%s%%)武魂破损", tonumber(myHpPercent)*100))
		self._ccbOwner.sp_my_blood_bar:setScaleX(0)
    	self._myDragonAvatar:setOpacity(150)
    else
		self._ccbOwner.tf_my_blood:setString(string.format("(受到总伤害：%s%%)%s%s/%s%s", tonumber(myHpPercent)*100, myHp, myUint, myFullHp, myFullUint))
		self._ccbOwner.sp_my_blood_bar:setScaleX(self._myBloodScaleX * myDragonHp/myDragonFullHp)
    	self._ccbOwner.sp_my_lose:setVisible(false)
	end	

	-- enemyDragonHp
	-- local enemyDragonHp = self._enemyFighterInfo.dragonCurrHp or 0
	-- local enemyDragonFullHurt = self._enemyFighterInfo.dragonHurtHp or 0
	local enemyDragonHp = self._tempCurEnemyDragonHp
	local enemyDragonFullHurt = self._tempCurEnemyDragonFullHurt
	local enemyDragonFullHp = self._enemyFighterInfo.dragonFullHp or 0
	local ememyHp, ememyUint = q.convertLargerNumber(enemyDragonHp)
	local enemyFullHp, enemyFullUint = q.convertLargerNumber(enemyDragonFullHp)
	local enemyHpPercent = string.format("%.4f", (enemyDragonFullHurt/enemyDragonFullHp or 0))
	if enemyDragonHp ~= enemyDragonFullHp and tonumber(enemyHpPercent) < 0.0001 then
		enemyHpPercent = 0.0001
	end
	if enemyDragonHp <= 0 then
		self._ccbOwner.tf_enemy_blood:setString(string.format("(受到总伤害：%s%%)武魂破损", tonumber(enemyHpPercent)*100))
		self._ccbOwner.sp_enemy_blood_bar:setScaleX(0)
  		self._enemyDragonAvatar:setOpacity(150)
    else
		self._ccbOwner.tf_enemy_blood:setString(string.format("(受到总伤害：%s%%)%s%s/%s%s", tonumber(enemyHpPercent)*100, ememyHp, ememyUint, enemyFullHp, enemyFullUint))
		self._ccbOwner.sp_enemy_blood_bar:setScaleX(self._enemyBloodScaleX * enemyDragonHp/enemyDragonFullHp)
		self._ccbOwner.sp_enemy_lose:setVisible(false)
	end

	local isWin = remote.unionDragonWar:getFightResult(self._myFighterInfo, self._enemyFighterInfo)
	if isOpen then
		self._ccbOwner.sp_my_lead:setVisible(tonumber(myHpPercent) < tonumber(enemyHpPercent))
		self._ccbOwner.sp_enemy_lead:setVisible(tonumber(enemyHpPercent) < tonumber(myHpPercent))
	else
		if isWin then
    		self._enemyDragonAvatar:pauseAnimation()
    		makeNodeFromNormalToGray(self._ccbOwner.node_enemy_avatar)
    	else
    		self._myDragonAvatar:pauseAnimation()
    		makeNodeFromNormalToGray(self._ccbOwner.node_my_avatar)
    	end
    	self._ccbOwner.sp_my_lead:setVisible(false)
    	self._ccbOwner.sp_enemy_lead:setVisible(false)
        self._ccbOwner.sp_my_win:setVisible(isWin)
	    self._ccbOwner.sp_enemy_lose:setVisible(isWin)
        self._ccbOwner.sp_my_lose:setVisible(not isWin)
	    self._ccbOwner.sp_enemy_win:setVisible(not isWin)
	end

	-- set enemy win buffer
	self._ccbOwner.sp_enemy_win_buffer:setVisible(false)
end

function QUIDialogUnionDragonWar:setBossHurtInfo(event)
    if event.info == nil then return end

    table.insert(self._hurtList, event.info)

    self:showBossHurtInfo()
end

function QUIDialogUnionDragonWar:showBossHurtInfo()
	if self._isShowHurt then
		return
	end

    local info = self._hurtList[1]
    if not info then return end
    table.remove(self._hurtList, 1)

    local hurtHp = info.hurtNum
    local nodeAvatar
    if info.consortiaId == remote.user.userConsortia.consortiaId then
    	nodeAvatar = self._ccbOwner.node_enemy_effect

    	-- 自己的不用减
    	if info.userName ~= remote.user.nickname then
	    	self._tempCurEnemyDragonHp = self._tempCurEnemyDragonHp - hurtHp
	    	self._tempCurEnemyDragonFullHurt = self._tempCurEnemyDragonFullHurt + hurtHp
	    	if self._tempCurEnemyDragonHp < 0 then
	    		self._tempCurEnemyDragonHp = 0
	    	end
	    end
    else
    	nodeAvatar = self._ccbOwner.node_my_effect
    	self._tempCurMyDragonHp = self._tempCurMyDragonHp - hurtHp
    	self._tempCurMyDragonFullHurt = self._tempCurMyDragonFullHurt + hurtHp
    	if self._tempCurMyDragonHp < 0 then
    		self._tempCurMyDragonHp = 0
    	end
    end
    nodeAvatar:removeAllChildren()

    self._isShowHurt = true
    local scale = 1
    local posY = 50
    local ccbFile = "ccb/effects/xdaoguangdonghua_1.ccbi"
    local animationPlayer = QUIWidgetAnimationPlayer.new()
    animationPlayer:setPositionY(posY)
    animationPlayer:setScale(scale)
    animationPlayer:playAnimation(ccbFile,nil,function ()
        animationPlayer:removeFromParent()
    end)
    nodeAvatar:addChild(animationPlayer)

    if self._hurtScheduler ~= nil then
    	scheduler.unscheduleGlobal(self._hurtScheduler)
    	self._hurtScheduler = nil
    end
    
    self._hurtScheduler = scheduler.performWithDelayGlobal(function ()
        local richText = QRichText.new()
        richText:setPositionY(posY)
        local strokeColor = ccc3(0,0,0)
        local num,unit = q.convertLargerNumber(hurtHp)
        richText:setAnchorPoint(0.5,0.5)
        richText:setString({
                {oType = "font", content = info.unionName or "", strokeColor = strokeColor, size = 22,color = QIDEA_QUALITY_COLOR.YELLOW, fontName = global.font_name},
                {oType = "font", content = info.userName or "", strokeColor = strokeColor, size = 22,color = UNITY_COLOR.white, fontName = global.font_name},
                {oType = "font", content = "打出伤害"..num..(unit or ""), strokeColor = strokeColor, size = 22,color = QIDEA_QUALITY_COLOR.YELLOW},
            },790)
        nodeAvatar:addChild(richText)

        local arr = CCArray:create()
        arr:addObject(CCFadeIn:create(4/30))
        arr:addObject(CCDelayTime:create(17/30))
        local arr2 = CCArray:create()
        arr2:addObject(CCMoveTo:create(25/30,ccp(0, 78)))
        arr2:addObject(CCFadeOut:create(25/30))
        arr:addObject(CCSpawn:create(arr2))
        arr:addObject(CCCallFunc:create(function()
        		richText:removeFromParent()
        		self._isShowHurt = false
        		self:updateDragonHpInfo(true)
                self:showBossHurtInfo()
            end))
        richText:runAction(CCSequence:create(arr))
    end, 0.2)
end

function QUIDialogUnionDragonWar:setTopRanks()
	local ranks = remote.unionDragonWar:getTop5Ranks()
	for i = 1, 8 do
		self._ccbOwner["tf_name_"..i]:setString("虚位以待")
		self._ccbOwner["tf_name_"..i]:setColor(GAME_COLOR_SHADOW.notactive)
		if ranks[i] then
			self._ccbOwner["tf_name_"..i]:setString(ranks[i].memberName or "")
			if ranks[i].consortiaId == remote.user.userConsortia.consortiaId then
				self._ccbOwner["tf_name_"..i]:setColor(ccc3(159, 209, 251))
			else
				self._ccbOwner["tf_name_"..i]:setColor(ccc3(244, 150, 136))
			end
		end
	end
end

--检查小红点
function QUIDialogUnionDragonWar:checkRedTips()
	self._ccbOwner.sp_award_tips:setVisible(remote.unionDragonWar:checkDragonDailyAward())

	self._ccbOwner.sp_shop_tips:setVisible(remote.unionDragonWar:checkDragonWarShopTip())

	self._ccbOwner.sp_record_tips:setVisible(false)
end

function QUIDialogUnionDragonWar:checkWeather()
	local weather = remote.unionDragonWar:getUnionDragonWarWeather()
	local icon = CCSprite:create(weather.weather_icon)
	self._ccbOwner.node_weather:removeAllChildren()
	self._ccbOwner.node_weather:addChild(icon)
	self._ccbOwner.tf_weather_name:setString(weather.name)

	self:_showWeatherEffect()
end

function QUIDialogUnionDragonWar:checkScoreReward()
	local awardInfo = remote.unionDragonWar:getDragonWarScoreRewards()
	if q.isEmpty(awardInfo) then return end


	local floorDialog = function()
		if awardInfo.oldFloor < awardInfo.newFloor and awardInfo.floorReward ~= nil and awardInfo.floorReward ~= "" then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass="QUIDialogUnionDragonWarFloorUpgrade",
				options = {rewardInfo = awardInfo, callBack = function()
					remote.unionDragonWar:updateDragonWarScoreRewards(awardInfo.rewardId)
					self:checkScoreReward()	
				end},{isPopCurrentDialog = false}})
		else
			remote.unionDragonWar:updateDragonWarScoreRewards(awardInfo.rewardId)
		end
	end
	
	if awardInfo.rewardType == 0 and awardInfo.dailyReward and awardInfo.dailyReward ~= "" then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionDragonWarResultAwards",
			options = {awardInfo = awardInfo, callback = function()
				if floorDialog then
					floorDialog()
				end
			end}})
	elseif awardInfo.rewardType == 1 then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionDragonWarFloorInHerit",
				options = {rewardInfo = awardInfo, callBack = function ( ... )
					if floorDialog then
						awardInfo.oldFloor = 1
						floorDialog()
					end
				end}},{isPopCurrentDialog = false} )
	else
		remote.unionDragonWar:updateDragonWarScoreRewards(awardInfo.rewardId)
	end
end

function QUIDialogUnionDragonWar:setRankShowStated(isAnimation)
    self._ccbOwner.node_rank:stopAllActions()
    local posX = 0
    self._ccbOwner.tf_direction:setScaleX(1)
    if self._showRank then
    	posX = 220
    	self._ccbOwner.tf_direction:setScaleX(-1)
    end
    if isAnimation then
    	self._ccbOwner.node_rank:runAction(CCMoveTo:create(0.2, ccp(posX, 0)))
	else
    	self._ccbOwner.node_rank:setPositionX(posX)
	end
end

function QUIDialogUnionDragonWar:checkBuffTip()
	local isShowBuff, endAt = remote.unionDragonWar:checkMyHolyBuffer()
	if isShowBuff then
		local lastTime = app:getUserOperateRecord():getDragonWarBuffTipTime()
		if lastTime == nil or ((q.serverTime() - lastTime) > (24 * HOUR)) then
			app:getUserOperateRecord():setDragonWarBuffTipTime(q.serverTime())
			self._ccbOwner.node_holy_buffer:setVisible(false)
		    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogUnionDragonWarBuffTip",
		        options = {endAt = endAt, callBack = function()
					self._ccbOwner.node_holy_buffer:setVisible(true)
					self._ccbOwner.node_holy_buffer:setPosition(ccp(0, display.height/2))

					self._ccbOwner.node_holy_buffer:runAction(CCMoveTo:create(0.3, ccp(330, 28)))
		        end}})
		end
	end
end

function QUIDialogUnionDragonWar:_onTriggerPlus(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_plus) == false then return end
    app.sound:playSound("common_small")
    
    self:_onPlusHandler()
end

function QUIDialogUnionDragonWar:_onPlusHandler(event)
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCountBase",
        options = {cls = "QBuyCountDragonWar", buyCallback = function ()
            --app.tip:floatTip("购买成功～")
        end}})

    return true
end

function QUIDialogUnionDragonWar:_onTriggerAttack(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_attack) == false then return end
    app.sound:playSound("common_small")

	-- local isOpen, opentTime, closeTime = remote.unionDragonWar:checkDragonWarOpen()
	-- if isOpen then
	-- 	if (closeTime - q.serverTime()) <= 300 then
	-- 		app.tip:floatTip("魂师大人，斗场管理人员正在进行结算，请稍后再来～")
	-- 		return
	-- 	end
	-- end

    if self._count == 0 then
        if self:_onPlusHandler() == false then
            app.tip:floatTip("挑战次数已达到上限")
        end
        return
    end

	if remote.unionDragonWar:checkCanFastBattle() then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionDragonWarCheckFastBattle", 
			options = {callback = handler(self, self._startBattle)}})
	else
		self:_startBattle()
	end
end

function QUIDialogUnionDragonWar:_startBattle()
	local myInfo = {avatar = remote.user.avatar, name = remote.user.nickname}
	local dragonArrangement = QUnionDragonWarArrangement.new({teamKey = remote.teamManager.UNION_DRAGON_WAR_ATTACK_TEAM, myInfo = myInfo, info = self:getOptions()})
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement",
     	options = {arrangement = dragonArrangement}})
end

function QUIDialogUnionDragonWar:_onTriggerRule(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_help) == false then return end
    app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionDragonWarRule"})
end

function QUIDialogUnionDragonWar:_onTriggerRank(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_rank) == false then return end
    app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionDragonWarRankAwards"})
end

function QUIDialogUnionDragonWar:_onTriggerTopRank(event)
    app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionDragonWarRankAwards", options = {tab = "TAB_PERSONAL_RANK"}})
end

function QUIDialogUnionDragonWar:_onTriggerAwards(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_awards) == false then return end
    app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionDragonWarAwards"})
end

function QUIDialogUnionDragonWar:_onTriggerMySkill(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_my_skill) == false then return end
    app.sound:playSound("common_small")

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionDragonWarCurSkill", 
        options = {fighter = self._myFighterInfo}})
end

function QUIDialogUnionDragonWar:_onTriggerEnemySkill(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_enemy_skill) == false then return end
    app.sound:playSound("common_small")

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionDragonWarCurSkill", 
        options = {fighter = self._enemyFighterInfo}})
end

function QUIDialogUnionDragonWar:_onTriggerWinBuffer(event)
    if q.buttonEventShadow(event, self._ccbOwner.node_win_buffer) == false then return end
    app.sound:playSound("common_small")

	local myStreakWin = self._myFighterInfo.streakWin or 1
	local data = remote.unionDragonWar:getUnionDragonWinBuffer(myStreakWin)
	if data == nil then return end

    app.tip:floatTip("您的宗门连胜"..myStreakWin.."场，您接下来的每次伤害均可获得"..tostring(data).."%的提升")
end

function QUIDialogUnionDragonWar:_onTriggerHolyBuffer(event)
    if q.buttonEventShadow(event, self._ccbOwner.node_holy_buffer) == false then return end
    app.sound:playSound("common_small")

    local configuration = db:getConfiguration()
    local data = configuration["sociaty_dragon_holy_bonous"].value or 0
    local endAt = (self._myInfo.holyStsEndAt or 0)/1000 - q.serverTime()
    app.tip:floatTip("您的宗主为您开启了武魂祝福，在"..q.timeToHourMinuteSecond(endAt).."分内每次伤害均可获得"..(data*100).."%提升")
end

function QUIDialogUnionDragonWar:_onTriggerInfo(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_info) == false then return end
    app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionDragonWarInfo"})
end

function QUIDialogUnionDragonWar:_onTriggerBuff(event)
    if q.buttonEventShadow(event, self._ccbOwner.node_weather) == false then return end
	app.sound:playSound("common_small")

	local weather = remote.unionDragonWar:getUnionDragonWarWeather()
	local params = {}
	params.hideLevel = true
	params.showType = false
	params.skillNamePos = {x = 0, y = -20}
	params.skillTitle = weather.name
	params.showTitle = false

	app.tip:skillTip(weather.skill_id, 1, true, params)
end

function QUIDialogUnionDragonWar:_onTriggerGlory(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_glory) == false then return end
	app.sound:playSound("common_small")

	remote.unionDragonWar:dragonWarGetWallInfoRequest(function(data)
			local data = data.dragonWarGetWallInfoResponse.wallInfo or {}
			if next(data) then
		        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogDragonWarHistoryGlory", 
		        	options = {data = data}})
		    else
		    	app.tip:floatTip("魂师大人，赛季才刚刚开始哦～")
		    end
		end)
end

function QUIDialogUnionDragonWar:_onTriggerShop(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_shop) == false then return end
    app.sound:playSound("common_small")
    remote.stores:openShopDialog(SHOP_ID.dragonWarShop)
end

function QUIDialogUnionDragonWar:_onTriggerShowRank(event)
    app.sound:playSound("common_small")
    self._showRank = not self._showRank
    app:getUserOperateRecord():setDragonWarRankStated(self._showRank)

    self:setRankShowStated(true)
end

function QUIDialogUnionDragonWar:_showWeatherEffect()
	self._ccbOwner.node_weather_effect_fg:removeAllChildren()
	local weather = remote.unionDragonWar:getUnionDragonWarWeather()
	local fcaAnimation = QUIWidgetFcaAnimation.new(weather.ui_effect_id, "res")
	if fcaAnimation then
		fcaAnimation:playAnimation("animation", true)
		fcaAnimation:setScale(1.25)
		self._ccbOwner.node_weather_effect_fg:addChild(fcaAnimation)
	end
	self._ccbOwner.node_weather_effect_bg:removeAllChildren()
	if weather.ui_effect_type == 1 then
		local path = "ccb/effects/wuyun_1_1.ccbi"
		local effect = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.node_weather_effect_bg:addChild(effect)
		effect:playAnimation(path, nil, nil, false)
	end
end

return QUIDialogUnionDragonWar