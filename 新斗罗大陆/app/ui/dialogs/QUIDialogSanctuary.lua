--
-- zxs
-- 全大陆精英赛主界面
--

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSanctuary = class("QUIDialogSanctuary", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetSanctuaryRegister = import("..widgets.sanctuary.QUIWidgetSanctuaryRegister")
local QUIWidgetSanctuaryAuditionAndEnd = import("..widgets.sanctuary.QUIWidgetSanctuaryAuditionAndEnd")
local QUIWidgetSanctuaryEliminate = import("..widgets.sanctuary.QUIWidgetSanctuaryEliminate")
local QUIWidgetSanctuaryEliminateMap = import("..widgets.sanctuary.QUIWidgetSanctuaryEliminateMap")
local QSanctuaryDefenseArrangement = import("...arrangement.QSanctuaryDefenseArrangement")
local QNotificationCenter = import("...controllers.QNotificationCenter")

QUIDialogSanctuary.WIDGET_REGISTER = "WIDGET_REGISTER"
QUIDialogSanctuary.WIDGET_AUDITION_AND_END = "WIDGET_AUDITION_AND_END"
QUIDialogSanctuary.WIDGET_ELIMINATE_MAP = "WIDGET_ELIMINATE_MAP"
QUIDialogSanctuary.WIDGET_ELIMINATE = "WIDGET_ELIMINATE"

function QUIDialogSanctuary:ctor(options)
	local ccbFile = "ccb/Dialog_Sanctuary.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerRule", callback = handler(self, self._onTriggerRule)},
        {ccbCallbackName = "onTriggerShop", callback = handler(self, self._onTriggerShop)},
        {ccbCallbackName = "onTriggerRank", callback = handler(self, self._onTriggerRank)},
        {ccbCallbackName = "onTriggerMyRecord", callback = handler(self, self._onTriggerMyRecord)},
        {ccbCallbackName = "onTriggerBetRecord", callback = handler(self, self._onTriggerBetRecord)},
        {ccbCallbackName = "onTriggerAllRecord", callback = handler(self, self._onTriggerAllRecord)},
        {ccbCallbackName = "onTriggerTeam", callback = handler(self, self._onTriggerTeam)},
        {ccbCallbackName = "onTriggerClickPVP", callback = handler(self, self._onTriggerClickPVP)},   
	}
	QUIDialogSanctuary.super.ctor(self,ccbFile,callBacks,options)

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setAllUIVisible(false)
	page:setScalingVisible(false)
	if page.topBar then
    	page.topBar:showWithSanctuary()
    end
    
    CalculateUIBgSize(self._ccbOwner.node_bg, 1280)

    if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.SANCTUARY_TIPS) then
        app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.SANCTUARY_TIPS)
    end
	self._ccbOwner.tf_defens_force:setString(0)

    self._pvpNodePosX = self._ccbOwner.node_pvp:getPositionX()
end

function QUIDialogSanctuary:viewDidAppear()
	QUIDialogSanctuary.super.viewDidAppear(self)
	self:addBackEvent(false)

	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)
	
	self._sanctuaryProxy = cc.EventProxy.new(remote.sanctuary)
	self._sanctuaryProxy:addEventListener(remote.sanctuary.EVENT_SANCTUARY_TIME_UPDATE, handler(self, self._updateTimeHandler))
	self._sanctuaryProxy:addEventListener(remote.sanctuary.EVENT_SANCTUARY_MY_UPDATE, handler(self, self._updateMyInfoHandler))

	local callback = function()
		-- 更新界面
		self:updatePanel()
		-- 红点
		self:checkRedTips()

		--打开界面的时候去更新防守阵容
		remote.sanctuary:checkDefenseUpdate(function ()
			self:showDefenseForce()
		end)

		-- 引导
		self:checkGuiad()
		remote.sanctuary:setStateChangeTips(false)
	end

	local needUpdate = remote.sanctuary:getStateChangeTips()
	if needUpdate then
		remote.sanctuary:sanctuaryWarInfoRequest(function()
			if self:safeCheck() then
				callback()
			end
		end)
	else
		callback()
	end
end

function QUIDialogSanctuary:viewWillDisappear()
	QUIDialogSanctuary.super.viewWillDisappear(self)
	self:removeBackEvent(false)

	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)
	if self._sanctuaryProxy ~= nil then
		self._sanctuaryProxy:removeAllEventListeners()
		self._sanctuaryProxy = nil
	end
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
end

function QUIDialogSanctuary:checkGuiad()
	if not app.tutorial or not app.tutorial:isInTutorial() then
		self:checkSendAwards()
	end
end

function QUIDialogSanctuary:checkSendAwards()
	local gotSendMoney = remote.sanctuary:getIsGotSendMoney()
	if not gotSendMoney then
		local callback = function()
			remote.sanctuary:sanctuaryWarGetSendMoneyRequest()
		end
    	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSanctuaryInvitation",
    		options = {isGuide = true, callback = callback}}, {isPopCurrentDialog = false})
	end
end

function QUIDialogSanctuary:showDefenseForce()
	local teamInfo = remote.sanctuary:getTeamInfo()
	local force = teamInfo.force or 0
	local num,unit = q.convertLargerNumber(force)
	self._ccbOwner.tf_defens_force:setString(num..(unit or ""))

	local fontInfo = db:getForceColorByForce(force, true)
	local color = string.split(fontInfo.force_color, ";")
	self._ccbOwner.tf_defens_force:setColor(ccc3(color[1], color[2], color[3]))

	self._ccbOwner.node_pvp:setVisible(ENABLE_PVP_FORCE)
	self._ccbOwner.node_pvp:setPositionX( self._pvpNodePosX + self._ccbOwner.tf_defens_force:getContentSize().width)

	local isRedTips = remote.sanctuary:checkTeamRedTips()
	self._ccbOwner.sp_team_tips:setVisible(isRedTips)
end

function QUIDialogSanctuary:checkShowAnnounce()
	local showNum = remote.sanctuary:checkSanctuaryShowTips()
	local lastShowNum = app:getUserOperateRecord():getSanctuaryShowAnnouce(2) or 0
	if showNum ~= 0 and showNum ~= lastShowNum then
		app:getUserOperateRecord():setSanctuaryShowAnnouce(2, showNum)
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSanctuaryAnnounce"}, {isPopCurrentDialog = false})
	end
end

function QUIDialogSanctuary:checkRedTips()
	self._ccbOwner.sp_my_record_tips:setVisible(false)

	if remote.sanctuary:checkShopRedTips() then
		self._ccbOwner.sp_shop_tips:setVisible(true)
	else
		self._ccbOwner.sp_shop_tips:setVisible(false)
	end
end

-- 根据信息判断显示那个widget(停赛、报名、海选、淘汰)
function QUIDialogSanctuary:updatePanel()
	local state = remote.sanctuary:getState()
	self:updateDescPosition(true)
	if state == remote.sanctuary.STATE_NONE then
		self:showAuditionAndEnd()
	elseif state == remote.sanctuary.STATE_REGISTER then
		self:showRegister()
	elseif state == remote.sanctuary.STATE_MATCH_OPPONENT then
		self:showAuditionAndEnd()
	elseif state == remote.sanctuary.STATE_AUDITION_1 or state == remote.sanctuary.STATE_AUDITION_2 or state == remote.sanctuary.STATE_AUDITION_1_END then
		self:showAuditionAndEnd()
	elseif state == remote.sanctuary.STATE_AUDITION_2_END then
		self:showEliminateMap()
		self:updateDescPosition(false)
	elseif state == remote.sanctuary.STATE_KNOCKOUT_64 or state == remote.sanctuary.STATE_KNOCKOUT_32 or state == remote.sanctuary.STATE_KNOCKOUT_16 then
		self:showEliminateMap()
		self:updateDescPosition(false)
	elseif state == remote.sanctuary.STATE_KNOCKOUT_8_OUT then
		self:showEliminate()
	elseif state == remote.sanctuary.STATE_BETS_8 or state == remote.sanctuary.STATE_BETS_4 or state == remote.sanctuary.STATE_BETS_2 then
		self:showEliminate()
	elseif state == remote.sanctuary.STATE_KNOCKOUT_8 or state == remote.sanctuary.STATE_KNOCKOUT_4 or 
		state == remote.sanctuary.STATE_KNOCKOUT_4_OUT or state == remote.sanctuary.STATE_KNOCKOUT_2_OUT then
		self:showEliminate()
	elseif state == remote.sanctuary.STATE_FINAL then
		self:showEliminate()
	elseif state == remote.sanctuary.STATE_ALL_END then
		self:showAuditionAndEnd()
	end

	self:countTime()

	local isOpen = remote.sanctuary:getIsServerOpen()
	if isOpen then
		-- 检测公告
		self:checkShowAnnounce()
		self:getResultList()
	end
end

function QUIDialogSanctuary:updateDescPosition(isNomal)
	if isNomal then
		self._ccbOwner.node_desc:setPosition(ccp(0, -168))
	else
		self._ccbOwner.node_desc:setPosition(ccp(-230, -115))
	end
end

--获取结果列表
function QUIDialogSanctuary:getResultList()
	remote.sanctuary:sanctuaryWarRewardListRequest(function (data)
		local rewards = data.sanctuaryWarRewardListResponse.rewards or {}
		local getAwardsFun
		getAwardsFun = function ()
			if #rewards > 0 then
				local award = table.remove(rewards,1)
				if award.currRound == remote.sanctuary.AUDITION_2 then
					getAwardsFun()
				else
					self:getEliminateResult(award, getAwardsFun)
				end
			end
		end
		getAwardsFun()
	end)
end

-- 奖励
function QUIDialogSanctuary:getEliminateResult(award, callback)
	remote.sanctuary:sanctuaryWarGetRewardRequest(award.rewardId, function ()
		local gameName = ""
		local winDesc = "并成功晋级！"
		local scoreDesc = "积分+"..(award.addScore or 0)
		if award.currRound == remote.sanctuary.ROUND_64 then
			gameName = "64强赛"
		elseif award.currRound == remote.sanctuary.ROUND_32 then
			gameName = "32强赛"
		elseif award.currRound == remote.sanctuary.ROUND_16 then
			gameName = "16强赛"
		elseif award.currRound == remote.sanctuary.ROUND_8 then
			gameName = "8强赛"
		elseif award.currRound == remote.sanctuary.ROUND_4 then
			gameName = "半决赛"
		elseif award.currRound == remote.sanctuary.ROUND_2 then
			if award.isThirdRound then
				gameName = "季军赛"
				winDesc = "并成功获得季军！"
			else
				gameName = "决赛"
				winDesc = "并成功获得冠军！"
			end
		end
		
		local awards = {}
		remote.items:analysisServerItem(award.rewardInfo, awards)
		local options = {awards = awards, callback = callback}
		if award.success == true then
	    	local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogWin", options = options}, {isPopCurrentDialog = true})
	    	dialog:setDesc("魂师大人，您在"..gameName.."中以 "..award.scoreInfo.." 战胜对手"..winDesc..scoreDesc.."，这是您的奖励哟")
		else
	    	local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogLose", options = options}, {isPopCurrentDialog = true})
	    	dialog:setDesc("魂师大人，您在"..gameName.."中以 "..award.scoreInfo.." 不幸落败淘汰！"..scoreDesc.."，这是您的奖励哟")
		end
	end)
end

function QUIDialogSanctuary:countTime()
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
	local curConfig = remote.sanctuary:getCurrentConfig()
	local isSeason = remote.sanctuary:getIsInSeasonTime()
	local myIndex = remote.sanctuary:getMyPageIndex()
	local desc = curConfig.desc
	if myIndex == 0 then
		desc = curConfig.desc
	else
		desc = curConfig.desc_2
	end

	if curConfig and desc and isSeason then
		self._ccbOwner.node_desc:setVisible(true)
		
		local diffTime = curConfig.endAt - q.serverTime()
		local updateTime = function()
			if diffTime >= 0 then
				local timeStr = q.timeToDayHourMinute(diffTime)
				self._ccbOwner.tf_tips:setString(desc.."倒计时："..timeStr)
			else
				if self._timeHandler ~= nil then
					scheduler.unscheduleGlobal(self._timeHandler)
					self._timeHandler = nil
				end
				self._ccbOwner.tf_tips:setString("正在结算中")
			end
			diffTime = diffTime - 1
		end

		-- 是否显示倒计时
		if curConfig.show_time == 1 then
			self._timeHandler = scheduler.scheduleGlobal(function ()
				updateTime()
			end, 1)
			updateTime()
		else
			self._ccbOwner.tf_tips:setString(desc)
		end
	else
		self._ccbOwner.node_desc:setVisible(false)
	end

	-- 休赛一周
	if curConfig and curConfig.state == remote.sanctuary.STATE_NONE then
		self._ccbOwner.node_desc:setVisible(true)
		local isOpen = remote.sanctuary:getIsServerOpen()
		if isOpen then
			self._ccbOwner.tf_tips:setString(desc)
		else
			local nextStartAt = remote.sanctuary:getSeasonStartTime()/1000 + 2*WEEK
			local timeStr = q.timeToMonthDayHourMin(nextStartAt)
			self._ccbOwner.tf_tips:setString("下届开始时间："..timeStr)
		end
	end
end

function QUIDialogSanctuary:showRegister()
	if self._state == QUIDialogSanctuary.WIDGET_REGISTER then
		self._widget:switchState()
	else
		if self._widget ~= nil then
			self._widget:removeFromParent()
			self._widget = nil
		end
		self._widget = QUIWidgetSanctuaryRegister.new()
		self._ccbOwner.node_content:addChild(self._widget)
		self._state = QUIDialogSanctuary.WIDGET_REGISTER
	end
end

function QUIDialogSanctuary:showAuditionAndEnd()
	if self._state == QUIDialogSanctuary.WIDGET_AUDITION_AND_END then
		self._widget:switchState()
	else
		if self._widget ~= nil then
			self._widget:removeFromParent()
			self._widget = nil
		end
		self._widget = QUIWidgetSanctuaryAuditionAndEnd.new()
		self._ccbOwner.node_content:addChild(self._widget)
		self._state = QUIDialogSanctuary.WIDGET_AUDITION_AND_END
	end
end

function QUIDialogSanctuary:showEliminateMap()
	if self._state == QUIDialogSanctuary.WIDGET_ELIMINATE_MAP then
		self._widget:switchState()
	else
		if self._widget ~= nil then
			self._widget:removeFromParent()
			self._widget = nil
		end
		self._widget = QUIWidgetSanctuaryEliminateMap.new(self:getOptions())
		self._ccbOwner.node_content:addChild(self._widget)
		self._state = QUIDialogSanctuary.STATE_WIDGET_ELIMINATE_64
	end
end

function QUIDialogSanctuary:showEliminate()
	if self._state == QUIDialogSanctuary.WIDGET_ELIMINATE then
		self._widget:switchState()
	else
		if self._widget ~= nil then
			self._widget:removeFromParent()
			self._widget = nil
		end
		self._widget = QUIWidgetSanctuaryEliminate.new(self:getOptions())
		self._ccbOwner.node_content:addChild(self._widget)
		self._state = QUIDialogSanctuary.WIDGET_ELIMINATE
	end
end

------------------------event-----------------------------
--时间点刷新了
function QUIDialogSanctuary:_updateTimeHandler(event)
	remote.sanctuary:sanctuaryWarInfoRequest(function()
		if self:safeCheck() then
			remote.sanctuary:resetTimeCount()
			self:updatePanel()
			self:showDefenseForce()
		end
	end)
end

function QUIDialogSanctuary:_updateMyInfoHandler(event)
	self:updatePanel()
end

--战斗结束
function QUIDialogSanctuary:exitFromBattleHandler()
	self:updatePanel()
	remote.sanctuary:setOldFighter()
end

-- 引导打开介绍
function QUIDialogSanctuary:showDescription()
	local callback = function()
		self:checkSendAwards()
	end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSanctuaryTutorialDialog", options = {callback = callback}}, {isPopCurrentDialog = false})
end

function QUIDialogSanctuary:_onTriggerTeam(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_team) == false then return end
    
    app.sound:playSound("common_small")
    local isSign = false

    local changeTeam = function(isSignTeam)
		local sanctuaryDefenseArrangement1 = QSanctuaryDefenseArrangement.new({teamKey = remote.teamManager.SANCTUARY_DEFEND_TEAM1, isSign = isSign})
		local sanctuaryDefenseArrangement2 = QSanctuaryDefenseArrangement.new({teamKey = remote.teamManager.SANCTUARY_DEFEND_TEAM2, isSign = isSign})
		local dialog = app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMetalCityTeamArrangement",
			options = {arrangement1 = sanctuaryDefenseArrangement1, arrangement2 = sanctuaryDefenseArrangement2, defense = true, isStromArena = true, widgetClass = "QUIWidgetStormArenaTeamBossInfo"}})
    end

	local isSeason = remote.sanctuary:getIsInSeasonTime()
	if not isSeason then
		changeTeam(false)
		-- app.tip:floatTip("停赛期间不可调整阵容！")
		return 
	end
	local myInfo = remote.sanctuary:getSanctuaryMyInfo()
	if myInfo == nil then
		app.tip:floatTip("全大陆精英赛尚未开启！")
		return 
	end
	
	local stateConfig = remote.sanctuary:getCurrentConfig()
	if stateConfig.state == remote.sanctuary.STATE_REGISTER and not myInfo.signUp then
		isSign = true
	elseif stateConfig.changeTeam == false then
		app.tip:floatTip("当前阶段不可以调整阵容！")
		return 
	elseif not myInfo.signUp then
		app.tip:floatTip("魂师大人，您未报名，不可调整阵容！")
		return
	end

	changeTeam(isSign)

end

function QUIDialogSanctuary:_onTriggerClickPVP(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_pvp) == false then return end
    app.sound:playSound("common_small")

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPVPPropTip", 
        options = {teamKey = remote.teamManager.SANCTUARY_DEFEND_TEAM1, teamKey2 = remote.teamManager.SANCTUARY_DEFEND_TEAM2, showTeam = true}}, {isPopCurrentDialog = false})
end

function QUIDialogSanctuary:_onTriggerRule(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_help) == false then return end
    app.sound:playSound("common_small")
  	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSanctuaryRule"}, {isPopCurrentDialog = false})
end

function QUIDialogSanctuary:_onTriggerShop(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_shop) == false then return end
    app.sound:playSound("common_small")
	remote.stores:openShopDialog(SHOP_ID.sanctuaryShop)
end

function QUIDialogSanctuary:_onTriggerRank(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_rank) == false then return end
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRank", 
		options = {initRank = "sanctuary"}}, {isPopCurrentDialog = false})
end

function QUIDialogSanctuary:_onTriggerMyRecord(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_my_record) == false then return end
    app.sound:playSound("common_small")

    remote.sanctuary:sanctuaryWarGetMyReportRequest(function (data)
    	local reports = data.sanctuaryWarGetReportResponse.reports or {}
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSanctuaryMyRecord", 
			options = {reports = reports, selectTab = "TAB_AUDITION"}}, {isPopCurrentDialog = false})
	end)
end

function QUIDialogSanctuary:_onTriggerAllRecord(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_all_record) == false then return end
    app.sound:playSound("common_small")

  	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSanctuaryAllRecord"}, {isPopCurrentDialog = false})
end

function QUIDialogSanctuary:_onTriggerBetRecord(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_bet_record) == false then return end
    app.sound:playSound("common_small")
    remote.sanctuary:sanctuaryWarGetBetInfoRequest(function (data)
	    local myBetList = {}
    	if data.sanctuaryWarGetBetInfoResponse.myInfo then
	    	myBetList = data.sanctuaryWarGetBetInfoResponse.myInfo.infos or {}
	    end
	    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSanctuaryBetRecord",
	    		options = {betList = myBetList}}, {isPopCurrentDialog = false})
    end)
end

function QUIDialogSanctuary:onTriggerBackHandler()
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogSanctuary:onTriggerHomeHandler()
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogSanctuary