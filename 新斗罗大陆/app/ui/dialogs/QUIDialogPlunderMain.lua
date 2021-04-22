--
-- Author: Kumo.Wang
-- Date: 
-- 宗门战二级场景
--
local QUIDialog = import(".QUIDialog")
local QUIDialogPlunderMain = class("QUIDialogPlunderMain", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIViewController = import("..QUIViewController")
local QPlunderDefenseArrangement = import("...arrangement.QPlunderDefenseArrangement")
local QChatData = import("...models.chatdata.QChatData")
local QUIWidgetChat = import("..widgets.QUIWidgetChat")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

local QUIWidgetPlunder = import("..widgets.QUIWidgetPlunder")
local QUIWidgetPlunderNormal = import("..widgets.QUIWidgetPlunderNormal")
local QUIWidgetPlunderSenior = import("..widgets.QUIWidgetPlunderSenior")
local QUIWidgetPlunderIcon = import("..widgets.QUIWidgetPlunderIcon")
local QUIWidgetSilverMineRecommend = import("..widgets.QUIWidgetSilverMineRecommend")
local QUIWidgetSilverMineName = import("..widgets.QUIWidgetSilverMineName")
local QDialogPlunderChooseCard = import("...ui.dialogs.QDialogPlunderChooseCard")
local QVIPUtil = import("...utils.QVIPUtil")


local SHARE_CD_LIMIT = "%d分钟内只允许发送%d条分享，%s后可以发送"
local SHARE_CD = 5 -- 5m
local SHARE_COUNT = 5

function QUIDialogPlunderMain:ctor(options)
	local ccbFile = "ccb/Dialog_plunder_main.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerRule", callback = handler(self, QUIDialogPlunderMain._onTriggerRule)},
		{ccbCallbackName = "onTriggerAward", callback = handler(self, QUIDialogPlunderMain._onTriggerAward)},
		{ccbCallbackName = "onTriggerPlus", callback = handler(self, QUIDialogPlunderMain._onTriggerPlus)},
		{ccbCallbackName = "onTriggerRank", callback = handler(self, QUIDialogPlunderMain._onTriggerRank)},
        {ccbCallbackName = "onTriggerTeam", callback = handler(self, QUIDialogPlunderMain._onTriggerTeam)},
        {ccbCallbackName = "onTriggerMineInfo", callback = handler(self, QUIDialogPlunderMain._onTriggerMineInfo)},
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, QUIDialogPlunderMain._onTriggerLeft)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, QUIDialogPlunderMain._onTriggerRight)},
		{ccbCallbackName = "onTriggerAutoFind", callback = handler(self, QUIDialogPlunderMain._onTriggerAutoFind)},
		{ccbCallbackName = "onTriggerShare", callback = handler(self, QUIDialogPlunderMain._onTriggerShare)},
		{ccbCallbackName = "onTriggerRecord", callback = handler(self, QUIDialogPlunderMain._onTriggerRecord)},
		{ccbCallbackName = "onTriggerShop", callback = handler(self, QUIDialogPlunderMain._onTriggerShop)},
        {ccbCallbackName = "onTriggerClickPVP", callback = handler(self, self._onTriggerClickPVP)},   
	}

	QUIDialogPlunderMain.super.ctor(self, ccbFile, callBacks, options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
 	page:setScalingVisible(false)
    page.topBar:showWithPlunder()

    CalculateUIBgSize(self._ccbOwner.node_bg, 1280)
    
 --    if not app:isNativeLargerEqualThan(1, 2, 1) then
	-- 	self._ccbOwner.tf_mine_info_title = setShadow5(self._ccbOwner.tf_mine_info_title)
	-- 	self._ccbOwner.tf_no_mine_title = setShadow5(self._ccbOwner.tf_no_mine_title)
	-- 	self._ccbOwner.tf_no_mine = setShadow5(self._ccbOwner.tf_no_mine)
	-- end

    remote.plunder:plunderGetMyInfoRequest()
    self._caveId = options.caveId
    self._myMineId = options.myMineId -- 用于定位到自己的魂兽区
    self._recommendMineId = options.recommendMineId
    local caveConfig = remote.plunder:getCaveConfigByCaveId( self._caveId )
    if caveConfig and caveConfig.cave_bonus and caveConfig.cave_bonus == 0 then
    	local mineIdList = string.split(caveConfig.mine_ids, ";")
    	remote.plunder:plunderGetLastCaveInfoRequest(self._myMineId or self._recommendMineId or mineIdList[1])
    else
    	remote.plunder:plunderGetCaveInfoRequest(self._caveId)
    end
    self._caveRegion = options.caveRegion or remote.plunder:getCurCavePage() or PAGE_NUMBER.ONE
    remote.plunder:setCurCavePage( self._caveRegion )
    
    self._mineList = {}
    self._mineIdList = {} -- 保存当前cave下面的mineId，以self._nodeCount分段
    -- self._curPageIndex = 1 -- 第几页
    self._caveConsortiaId = "" -- 当前场景加成宗门的id

    local index = 1
    while true do
		local node = self._ccbOwner["node_mine_"..index]
		if node then
			index = index + 1
		else
			break
		end
	end
	self._nodeCount = index - 1

	local cavesConfig = remote.plunder:getCaveConfigByCaveRegion( self._caveRegion )
	self._firstCaveId = cavesConfig[1].cave_id
	self._lastCaveId = cavesConfig[table.nums(cavesConfig)].cave_id

	--左下角聊天室按钮
	self.widgetChat = QUIWidgetChat.new()
	self.widgetChat:setPosition(0, 0)
	self.widgetChat:retain()

    -- remote.plunder:plunderGetCaveInfoRequest(self._caveId, function() self:_init() end)
	-- if not app:isNativeLargerEqualThan(1, 2, 1) then
	--     self._ccbOwner.tf_mine_time = setShadow5(self._ccbOwner.tf_mine_time)
	--     self._ccbOwner.tf_no_mine_title = setShadow5(self._ccbOwner.tf_no_mine_title)
	--     self._ccbOwner.tf_no_mine = setShadow5(self._ccbOwner.tf_no_mine)
	--     self._ccbOwner.tf_society_name_title = setShadow5(self._ccbOwner.tf_society_name_title)
	--     self._ccbOwner.tf_society_name = setShadow5(self._ccbOwner.tf_society_name)
	-- end
    
    self._nameWidget = QUIWidgetSilverMineName.new()
	self._ccbOwner.node_name_ccb:addChild(self._nameWidget)

	self._ccbOwner.sp_share_tips:setVisible(false)
	
    self._pvpNodePosX = self._ccbOwner.node_pvp:getPositionX()

    self:_init()
end

function QUIDialogPlunderMain:viewDidAppear()
	QUIDialogPlunderMain.super.viewDidAppear(self)
	self:_request()
	
	self._bgSound = app.sound:playSound("silvermin_sound", true)
	self._originalMusicVolume = audio.getMusicVolume()
	audio.setMusicVolume(audio.getMusicVolume() * 0.333)

    app:getNavigationManager():getController(app.mainUILayer):getTopPage().inSilverMinePage = true

	self:addBackEvent(false)
	self._plunderProxy = cc.EventProxy.new(remote.plunder)
    self._plunderProxy:addEventListener(remote.plunder.NEW_DAY, handler(self, self._updatePlunderHandler))
    self._plunderProxy:addEventListener(remote.plunder.MY_INFO_UPDATE, handler(self, self._updatePlunderHandler))
    self._plunderProxy:addEventListener(remote.plunder.CAVE_UPDATE, handler(self, self._updatePlunderHandler))
    self._plunderProxy:addEventListener(remote.plunder.MINE_UPDATE, handler(self, self._updatePlunderHandler))

	self._chatDataProxy = cc.EventProxy.new(app:getServerChatData())
    self._chatDataProxy:addEventListener(QChatData.NEW_MESSAGE_RECEIVED, handler(self, self._onMessageReceived))
    QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self._exitFromBattle, self)
	app:getNavigationManager():getController(app.mainUILayer):getTopPage():setChatButton(false)

    self._ccbOwner.node_chat:addChild(self.widgetChat)
    self.widgetChat:setChatAreaVisible(false)
	self.widgetChat:checkPrivateChannelRedTips()
	self.widgetChat:release()

	self:_checkChooseCardAwards()
    self:setSilverMineDefenseHero()
end

function QUIDialogPlunderMain:viewAnimationInHandler()
	-- if remote.plunder:getIsNeedShowAward() and remote.plunder:checkSilverMineAwardRedTip() then
	-- 	remote.plunder:setIsNeedShowAward( false )
	-- 	self:_onTriggerAward()
	-- end
end

function QUIDialogPlunderMain:_checkChooseCardAwards()
    local lootRandomAward = remote.plunder:getLootRandomAward()
    if lootRandomAward and lootRandomAward ~= "" and remote.plunder:getIsCanChooseCard() then
        local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
        self.dialogCard = QDialogPlunderChooseCard.new({rewrad = lootRandomAward}, {onCloseCard = function ( ... )
            page:setManyUIVisible(true)
            page:setBackBtnVisible(true)
            page:setScalingVisible(false)
            page.topBar:showWithSilverMine()
            self.dialogCard:removeFromParent()
        end})
        page:setManyUIVisible(false)
        page.topBar:hideAll()
        page:setBackBtnVisible(false)
        page:setScalingVisible(false)
        self.dialogCard:setPosition(ccp(0, 0))
        self:getView():addChild(self.dialogCard)
    end
    remote.plunder:setIsCanChooseCard( false )
end

function QUIDialogPlunderMain:viewWillDisappear()
	QUIDialogPlunderMain.super.viewWillDisappear(self)
    app:getNavigationManager():getController(app.mainUILayer):getTopPage().inSilverMinePage = false
	app:getNavigationManager():getController(app.mainUILayer):getTopPage():setChatButton(true)

	self:removeBackEvent()
	self._plunderProxy:removeAllEventListeners()

	self._chatDataProxy:removeAllEventListeners()
	self._chatDataProxy = nil

	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self._exitFromBattle, self)

	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end

	if self._bgSound then
		app.sound:stopSound(self._bgSound)
		self._bgSound = nil
	end

	audio.setMusicVolume(self._originalMusicVolume)

	remote.plunder:setIsNeedShowMineId( 0 )
end

function QUIDialogPlunderMain:gotoMine( caveId, caveRegion, mineId )
	-- print( "####", caveId, caveRegion, mineId, self._myMineId )
	if not caveId then return end
	local caveId = caveId
	if caveId == self._caveId and not mineId then
		app.tip:floatTip("魂师大人，您已在当前极北之地了")
		return
	end

	if caveId == self._caveId and mineId and mineId == self._myMineId then
		app.tip:floatTip("魂师大人，您已在当前极北之地了")
		return
	end

	if self._mineList and table.nums(self._mineList) > 0 then
		self._mineList = {}
	end
	self._caveId = caveId
	self:getOptions().caveId = self._caveId
	remote.plunder:plunderGetCaveInfoRequest(self._caveId, self:safeHandler(function()
			self._caveRegion = caveRegion or PAGE_NUMBER.ONE
			remote.plunder:setCurCavePage( self._caveRegion )
			self._myMineId = mineId
		    self._curPageIndex = 1
		    -- print("[Kumo] 清除小手指")
		    self._recommendMineId = nil
		    self:_init()
		end))
end

function QUIDialogPlunderMain:_updatePlunderHandler( event )
	-- print("[Kumo] QUIDialogPlunderMain:_updatePlunderHandler() ", event.name)
	if event.name == remote.plunder.NEW_DAY then
		self:_updateInfo()
	elseif event.name == remote.plunder.MY_INFO_UPDATE then
		-- self:_updateMine()
		self:_updateMapBuff()
		self:_updateInfo()
		self:_updateMyOccupy()
	elseif event.name == remote.plunder.CAVE_UPDATE then
		self:_updateMapBuff()
		self:_updateMine()
	elseif event.name == remote.plunder.MINE_UPDATE then
		self:_updateMapBuff()
		self:_updateMine()
		-- self:_updateInfo()
		-- self:_updateMyOccupy()
	end
end

function QUIDialogPlunderMain:_onMessageReceived(event)
	self.widgetChat:checkPrivateChannelRedTips()
end

function QUIDialogPlunderMain:_request()
	remote.plunder:plunderGetMyInfoRequest()
	if self._caveId then
    	remote.plunder:plunderGetCaveInfoRequest(self._caveId)
    end
    remote.plunder:plunderGetCaveListRequest(self._caveRegion)
end

function QUIDialogPlunderMain:onTriggerBackHandler()
	if remote.plunder:isLock() or remote.plunder:isAniLock() then return end
	if remote.plunder:checkUnionState() then return end

    remote.plunder:addLock()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogPlunderMain:_onTriggerRule()
	app.sound:playSound("common_small")
	if remote.plunder:isLock() or remote.plunder:isAniLock() then return end
	if remote.plunder:checkUnionState() then return end

    remote.plunder:addLock()
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPlunderHelp", options = {}})
end

function QUIDialogPlunderMain:_onTriggerAward()
	app.sound:playSound("common_small")
	if remote.plunder:isLock() or remote.plunder:isAniLock() then return end
	if remote.plunder:checkUnionState() then return end

    remote.plunder:addLock()
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlunderAwards"})
end

function QUIDialogPlunderMain:_onTriggerRecord()
	app.sound:playSound("common_small")
	if remote.plunder:isLock() or remote.plunder:isAniLock() then return end
	if remote.plunder:checkUnionState() then return end
	self._ccbOwner.sp_record_tips:setVisible(false)
    remote.plunder:addLock()
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPlunderBattleReport"}, 
		{isPopCurrentDialog = false})
end

function QUIDialogPlunderMain:_onTriggerShop()
	app.sound:playSound("common_small")
	if remote.plunder:checkUnionState() then return end
	remote.stores:openShopDialog(SHOP_ID.silverShop)
end

function QUIDialogPlunderMain:_onTriggerPlus(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_plus) == false then return end
	app.sound:playSound("common_small")
	if remote.plunder:isLock() or remote.plunder:isAniLock() then return end
	if remote.plunder:checkBurstIn() then return end 

    remote.plunder:addLock()
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCountBase", options = {cls = "QBuyCountUnionPlunder"}})
end

function QUIDialogPlunderMain:_onTriggerRank()
	app.sound:playSound("common_small")
	if remote.plunder:isLock() or remote.plunder:isAniLock() then return end
	if remote.plunder:checkUnionState() then return end

    remote.plunder:addLock()
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPlunderRank"}, {isPopCurrentDialog = false})
end

function QUIDialogPlunderMain:_onTriggerClickPVP(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_pvp) == false then return end
    app.sound:playSound("common_small")

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPVPPropTip", 
        options = {teamKey = remote.teamManager.PLUNDER_DEFEND_TEAM}}, {isPopCurrentDialog = false})
end

function QUIDialogPlunderMain:_onTriggerLeft()
	app.sound:playSound("common_small")
	if remote.plunder:isLockByTime() or remote.plunder:isAniLock() then return end
	if remote.plunder:checkBurstIn() then return end 

    remote.plunder:addLockByTime()
 	if self._curPageIndex == 1 then
 		self._caveId = self._caveId - 1
 		self:getOptions().caveId = self._caveId
 		if  self._mineList and table.nums(self._mineList) > 0 then
			self._mineList = {}
		end
 		-- remote.plunder:plunderGetCaveInfoRequest(self._caveId)
 		local caveConfig = remote.plunder:getCaveConfigByCaveId( self._caveId )
	    if caveConfig and caveConfig.cave_bonus and caveConfig.cave_bonus == 0 then
	    	local mineIdList = string.split(caveConfig.mine_ids, ";")
	    	remote.plunder:plunderGetLastCaveInfoRequest(mineIdList[1])
	    else
	    	remote.plunder:plunderGetCaveInfoRequest(self._caveId)
	    end
 		self:_initMineIdList()
 		self._curPageIndex = table.nums(self._mineIdList)
	else
		self._curPageIndex = self._curPageIndex - 1
		local caveConfig = remote.plunder:getCaveConfigByCaveId( self._caveId )
	    if caveConfig and caveConfig.cave_bonus and caveConfig.cave_bonus == 0 then
	    	remote.plunder:plunderGetLastCaveInfoRequest(self._mineIdList[self._curPageIndex][1])
	    end
		if  self._mineList and table.nums(self._mineList) > 0 then
			self._mineList = {}
		end
	end
	-- print("[Kumo] 清除小手指")
	self._recommendMineId = nil
	self._myMineId = nil
	remote.plunder:setIsNeedShowMineId( 0 )
	self:_updateMapBuff()
	self:_updateMine()
	self:_updateInfo()
	self:_updateBtnState()
end

function QUIDialogPlunderMain:_onTriggerRight()
	app.sound:playSound("common_small")
	if remote.plunder:isLockByTime() or remote.plunder:isAniLock() then return end
	if remote.plunder:checkBurstIn() then return end 

    remote.plunder:addLockByTime()
	if self._curPageIndex == table.nums(self._mineIdList) then
		self._caveId = self._caveId + 1
		self:getOptions().caveId = self._caveId
		if  self._mineList and table.nums(self._mineList) > 0 then
			self._mineList = {}
		end
		-- remote.plunder:plunderGetCaveInfoRequest(self._caveId)
		local caveConfig = remote.plunder:getCaveConfigByCaveId( self._caveId )
	    if caveConfig and caveConfig.cave_bonus and caveConfig.cave_bonus == 0 then
	    	local mineIdList = string.split(caveConfig.mine_ids, ";")
	    	remote.plunder:plunderGetLastCaveInfoRequest(mineIdList[1])
	    else
	    	remote.plunder:plunderGetCaveInfoRequest(self._caveId)
	    end
 		self:_initMineIdList()
 		self._curPageIndex = 1
	else
		self._curPageIndex = self._curPageIndex + 1
		local caveConfig = remote.plunder:getCaveConfigByCaveId( self._caveId )
	    if caveConfig and caveConfig.cave_bonus and caveConfig.cave_bonus == 0 then
	    	remote.plunder:plunderGetLastCaveInfoRequest(self._mineIdList[self._curPageIndex][1])
	    end
		if  self._mineList and table.nums(self._mineList) > 0 then
			self._mineList = {}
		end
	end
	-- print("[Kumo] 清除小手指")
	self._recommendMineId = nil
	self._myMineId = nil
	remote.plunder:setIsNeedShowMineId( 0 )
	self:_updateMapBuff()
	self:_updateMine()
	self:_updateInfo()
	self:_updateBtnState()
end


function QUIDialogPlunderMain:_onTriggerAutoFind(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_auto_find) == false then return end
	app.sound:playSound("common_small")
	if remote.plunder:isLock() or remote.plunder:isAniLock() then return end
	if remote.plunder:checkBurstIn() then return end 
 	remote.plunder:addLock( true )
	remote.plunder:plunderQuickFindLootMineRequest(self:safeHandler(function(response)
			local mineId = response.kuafuMineQuickFindLootMineResponse.mineId
			if mineId == 0 then
				-- 后端没找到符合要求的魂兽区
				app.tip:floatTip("魂师大人，未找到适合掠夺的魂兽区，请手动查找")
				return
			end
			local recommendMineId = mineId
			local caveConfig = remote.plunder:getCaveConfigByMineId(mineId)
			if caveConfig and table.nums(caveConfig) > 0 then
				if self._caveId ~= caveConfig.cave_id or (caveConfig.cave_bonus and caveConfig.cave_bonus == 0) then
					if self._mineList and table.nums(self._mineList) > 0 then
						self._mineList = {}
						-- print("[Kumo] QUIDialogPlunderMain:_onTriggerAutoFind() : 清空 ", table.nums(self._mineList))
					end
				end
				self._caveId = caveConfig.cave_id or 1001
				self:getOptions().caveId = self._caveId
			    if caveConfig.cave_bonus and caveConfig.cave_bonus == 0 then
			    	remote.plunder:plunderGetLastCaveInfoRequest(mineId, self:safeHandler(function()
						self._caveRegion = caveConfig.cave_region or PAGE_NUMBER.ONE
						-- print("[Kumo] 需要小手指")
						self._recommendMineId = recommendMineId
					    self._curPageIndex = 1
					    self:_init()
					end))
			    else
			    	remote.plunder:plunderGetCaveInfoRequest(self._caveId, self:safeHandler(function()
						self._caveRegion = caveConfig.cave_region or PAGE_NUMBER.ONE
						-- print("[Kumo] 需要小手指")
						self._recommendMineId = recommendMineId
					    self._curPageIndex = 1
					    self:_init()
					end))
			    end
			end
		end))
end

function QUIDialogPlunderMain:_onTriggerShare(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_share) == false then return end
	app.sound:playSound("common_small")
	if remote.plunder:checkBurstIn() then return end 

	remote.plunder:setIsShareRedTips( false )
	self._ccbOwner.sp_share_tips:setVisible(false)
	local earliestTime, replayCount = app:getServerChatData():getEarliestReplaySilverMineSentTime()
	if replayCount >= SHARE_COUNT and q.serverTime() - earliestTime < SHARE_CD * 60 then
		app.tip:floatTip(string.format(SHARE_CD_LIMIT, SHARE_CD, SHARE_COUNT, q.timeToHourMinuteSecond(SHARE_CD * 60 - (q.serverTime() - earliestTime), true)))
		return
	end

	local caveConfig = remote.plunder:getCaveConfigByCaveId( self._caveId )
	local myConsortiaId = remote.plunder:getMyConsortiaId() 
	if caveConfig.cave_bonus == 1 and myConsortiaId and myConsortiaId ~= "" then
		app:alert({content = "魂师大人，是否要共享极北之地信息至宗门频道，便于同宗门成员一起来狩猎并激活宗门加成？", title = "系统提示", 
                callback = function(state)
                    if state == ALERT_TYPE.CONFIRM then
                        local msg = string.format("##n我在##e《极北之地%s》##n，大家快来一起狩猎，超过三个有宗门加成哦", caveConfig.cave_name or "")
						app:getServerChatData():sendMessage(msg, 2, nil, nil, nil, {caveId = self._caveId, caveRegion = caveConfig.cave_region, caveName = caveConfig.cave_name, isPlunder = 1},
							function( code )
								if code  and code == 0 then
									app.tip:floatTip("魂师大人，已将分享极北之地信息至宗门频道啦")
									app:getServerChatData():setEarliestReplaySilverMineSentTime(q.serverTime())
								end
							end
						)
                    end
                end, isAnimation = false}, true, true)
	end
end

function QUIDialogPlunderMain:_onTriggerTeam(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_team) == false then return end
	app.sound:playSound("common_small")
	if remote.plunder:checkBurstIn() then return end 

	if remote.plunder:isLock() or remote.plunder:isAniLock() then return end
    remote.plunder:addLock()
	local silverMineDefenseArrangement = QPlunderDefenseArrangement.new({teamKey = remote.teamManager.PLUNDER_DEFEND_TEAM})
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement",
		options = {arrangement = silverMineDefenseArrangement, isBattle = true}})
end

function QUIDialogPlunderMain:_onTriggerMineInfo(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_mine_info) == false then return end
	app.sound:playSound("common_small")
	if remote.plunder:checkBurstIn() then return end 

	if remote.plunder:isLock() or remote.plunder:isAniLock() then return end
    remote.plunder:addLock()
	local myMineId = remote.plunder:getMyMineId()
	if not myMineId then return end
	local pageIndex, isFind = self:_getPagrIndex( myMineId )
	local caveConfig = remote.plunder:getCaveConfigByMineId(myMineId)
	if caveConfig and caveConfig.cave_id and caveConfig.cave_id == self._caveId and pageIndex == self._curPageIndex and isFind then
		app.tip:floatTip("魂师大人，您已在当前极北之地了")
		return
	end
	if caveConfig then
		if self._caveId ~= caveConfig.cave_id then
			if  self._mineList and table.nums(self._mineList) > 0 then
				self._mineList = {}
			end
		end
		self._caveId = caveConfig.cave_id or 1001
		self:getOptions().caveId = self._caveId
		if caveConfig and caveConfig.cave_bonus and caveConfig.cave_bonus == 0 then
	    	remote.plunder:plunderGetLastCaveInfoRequest(myMineId, self:safeHandler(function()
					self._caveRegion = caveConfig.cave_region or PAGE_NUMBER.ONE
					remote.plunder:setCurCavePage( self._caveRegion )
				    self._myMineId = myMineId
				    -- print("[Kumo] 清除小手指")
				    self._recommendMineId = nil
				    self:_init()
				end))
	    else
			remote.plunder:plunderGetCaveInfoRequest(self._caveId, self:safeHandler(function()
					self._caveRegion = caveConfig.cave_region or PAGE_NUMBER.ONE
					remote.plunder:setCurCavePage( self._caveRegion )
				    self._myMineId = myMineId
				    -- print("[Kumo] 清除小手指")
				    self._recommendMineId = nil
				    self:_init()
				end))
		end
	end
end

function QUIDialogPlunderMain:_exitFromBattle()
	-- while true do
	-- 	local dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	-- 	if dialog and dialog.__cname == "QUIDialogPlunderPlayerInfo" then
	-- 		app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
	-- 	else
	-- 		break
	-- 	end
	-- end
	self:_request()
	-- self:_updateMapBuff()
	-- self:_updateMine()
	-- self:_updateInfo()
	-- self:_updateMyOccupy()
	if remote.plunder:getIsShareRedTips() then
		local earliestTime, replayCount = app:getServerChatData():getEarliestReplaySilverMineSentTime()
		if not (replayCount >= SHARE_COUNT and q.serverTime() - earliestTime < SHARE_CD * 60) then
			self._ccbOwner.sp_share_tips:setVisible(true)
		end
	end
	if remote.plunder:getIsNeedShowMineId() > 0 then
    	self:_showMyMineAppear()
    end

    if remote.plunder.needInvestClock then
    	app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPlunderInvest"}, {isPopCurrentDialog = false})
    end
end

function QUIDialogPlunderMain:_showMyMineAppear()
	for _, mineWidget in pairs(self._mineList) do
		mineWidget:show()
	end
end

function QUIDialogPlunderMain:_onEvent(event)
	-- print("[Kumo] QUIDialogPlunderMain:_onEvent() ", event.name, event.mineId)
	app.sound:playSound("common_small")
	if remote.plunder:checkBurstIn() then return end 
	
	if event.name == QUIWidgetPlunder.EVENT_OK or event.name == QUIWidgetSilverMineRecommend.EVENT_OK then
		-- print("[Kumo] 清除小手指")
		self._ccbOwner.node_recommend:removeAllChildren()
		self._recommendMineId = nil
		self:getOptions().recommendMineId = nil
		self._myMineId = event.mineId
		self:getOptions().myMineId = event.mineId
		-- print("[Kumo] 警告！ 弹出QUIDialogPlunderMainMineInfo界面")
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlunderPlayerInfo", options = {mineId = event.mineId}})
	elseif event.name == QUIWidgetPlunder.EVENT_INFO then
		local userId = remote.plunder:getOwnerIdByMineId( event.mineId )
		remote.plunder:plunderQueryFighterRequest(userId, function(response)
				local data = response.kuafuMineQueryFighterResponse.fighter
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo", 
					options = {fighter = data, forceTitle = "防守战力：", specialTitle1 = "服务器名：", specialValue1 = data.game_area_name, isPVP = true}}, {isPopCurrentDialog = false})
			end)
	end
end

function QUIDialogPlunderMain:_init()
	remote.plunder:setIsNeedShowChangeAni(false)
	self:_initMineIdList()
	self:_updateBtnState()
	self:_initInfo()
	self:_initMine()
end

function QUIDialogPlunderMain:_updateBtnState()
	local caveConfig = remote.plunder:getCaveConfigByCaveRegion( self._caveRegion or remote.plunder:getCurCavePage() or SILVERMINEWAR_TYPE.SENIOR )
	self._firstCaveId = caveConfig[1].cave_id
	self._lastCaveId = caveConfig[table.nums(caveConfig)].cave_id

	if self._caveId == self._firstCaveId  then
		self._ccbOwner.arrowLeft:setVisible(false)
		self._ccbOwner.btn_left:setEnabled(false)
		self._ccbOwner.arrowRight:setVisible(true)
		self._ccbOwner.btn_right:setEnabled(true)
	elseif self._caveId == self._lastCaveId and self._curPageIndex == table.nums(self._mineIdList) then
		self._ccbOwner.arrowLeft:setVisible(true)
		self._ccbOwner.btn_left:setEnabled(true)
		self._ccbOwner.arrowRight:setVisible(false)
		self._ccbOwner.btn_right:setEnabled(false)
	else
		self._ccbOwner.arrowLeft:setVisible(true)
		self._ccbOwner.btn_left:setEnabled(true)
		self._ccbOwner.arrowRight:setVisible(true)
		self._ccbOwner.btn_right:setEnabled(true)
	end
end

function QUIDialogPlunderMain:_initInfo()
	self:_updateMap()
	self:_updateInfo()
	self:_updateMyOccupy()
	self:_updateMapBuff()
end

function QUIDialogPlunderMain:_updateMap()
	local bg = nil
	if not self._caveRegion then
		self._caveRegion = remote.plunder:getCurCavePage() or SILVERMINEWAR_TYPE.SENIOR
	end
	if self._caveRegion == PAGE_NUMBER.ONE then
		bg = QUIWidgetPlunderSenior.new()
	elseif self._caveRegion == PAGE_NUMBER.TWO then
		bg = QUIWidgetPlunderNormal.new()
	elseif self._caveRegion == PAGE_NUMBER.THREE then
		bg = QUIWidgetPlunderNormal.new()
	elseif self._caveRegion == PAGE_NUMBER.FOUR then
		bg = QUIWidgetPlunderNormal.new()
	elseif self._caveRegion == PAGE_NUMBER.FIVE then
		bg = QUIWidgetPlunderNormal.new()
	end
	self._ccbOwner.node_bg:removeAllChildren()
	self._ccbOwner.node_bg:addChild(bg)
end

function QUIDialogPlunderMain:_updateInfo()
	-- 分享按钮的小红点
	if remote.plunder:getIsShareRedTips() then
		local earliestTime, replayCount = app:getServerChatData():getEarliestReplaySilverMineSentTime()
		if not (replayCount >= SHARE_COUNT and q.serverTime() - earliestTime < SHARE_CD * 60) then
			self._ccbOwner.sp_share_tips:setVisible(true)
		end
	end

	local caveConfig = remote.plunder:getCaveConfigByCaveId( self._caveId )
	if caveConfig and table.nums(caveConfig) > 0 then
		local name = caveConfig.cave_name
		local s, e = string.find(name, "%d")
		if s then
			local a = string.sub(name, 1, s - 1)
        	local b = string.sub(name, s)
        	name = a.." "..b
		end
		local nameStr = ""
		if self._mineIdList and table.nums(self._mineIdList) > 1 then
			nameStr = name.." - "..self._curPageIndex
			if not self._nameWidget:getName() then
				self._nameWidget:setName( nameStr, true )
			elseif self._nameWidget:getName() ~= nameStr then
				self._nameWidget:stop()
				self._nameWidget:setName( nameStr, true )
				self._nameWidget:show()
				-- self._ccbOwner.tf_mine_name:setString( name.." - "..self._curPageIndex )
			end
			self._ccbOwner.node_share:setPositionX(150)
		else
			nameStr = name
			if not self._nameWidget:getName() then
				self._nameWidget:setName( nameStr )
			elseif self._nameWidget:getName() ~= nameStr then
				self._nameWidget:stop()
				self._nameWidget:setName( nameStr )
				self._nameWidget:show()
				-- self._ccbOwner.tf_mine_name:setString( name.." - "..self._curPageIndex )
			end
			self._ccbOwner.node_share:setPositionX(100)
		end
	end

	local myConsortiaId = remote.plunder:getMyConsortiaId()
	if not myConsortiaId or myConsortiaId == "" or not caveConfig or not caveConfig.cave_bonus or caveConfig.cave_bonus == 0 then
		self._ccbOwner.node_share:setVisible(false)
	else
		self._ccbOwner.node_share:setVisible(true)
	end

	local count = remote.plunder:getLootCnt()
	self._ccbOwner.tf_attack_count:setString(count)

	local buyCount = remote.plunder:getBuyLootCnt()
	local totalVIPNum = QVIPUtil:getCountByWordField("gh_ykz_ld_times", QVIPUtil:getMaxLevel())
	local totalNum = QVIPUtil:getCountByWordField("gh_ykz_ld_times")
	self._ccbOwner.btn_plus:setVisible(totalVIPNum > totalNum or totalNum > buyCount)
	self._ccbOwner.btn_plus_expand:setVisible(totalVIPNum > totalNum or totalNum > buyCount)

	local force = remote.plunder:getDefenseForce()
	local fontInfo = db:getForceColorByForce(tonumber(force),true)
	local force, forceUnit = q.convertLargerNumber(force)
	self._ccbOwner.tf_defens_force:setString(force..(forceUnit or ""))
	local color = string.split(fontInfo.force_color, ";")
	self._ccbOwner.tf_defens_force:setColor(ccc3(color[1], color[2], color[3]))

	self._ccbOwner.node_pvp:setVisible(ENABLE_PVP_FORCE)
	self._ccbOwner.node_pvp:setPositionX( self._pvpNodePosX + self._ccbOwner.tf_defens_force:getContentSize().width)
	
	self._ccbOwner.sp_team_tips:setVisible(not remote.teamManager:checkTeamStormIsFull(remote.teamManager.PLUNDER_DEFEND_TEAM))

	self._ccbOwner.tf_my_score:setString(remote.plunder:getMyScore())
	self._ccbOwner.tf_society_score:setString(remote.plunder:getConsortiaScore())
	local myRank = remote.plunder:getMyRank()
	if myRank == 0 then
		self._ccbOwner.tf_my_rank:setString("（未上榜）")
	else
		self._ccbOwner.tf_my_rank:setString("（第"..myRank.."名）")
	end
	local societyRank = remote.plunder:getConsortiaRank()
	if societyRank == 0 then
		self._ccbOwner.tf_society_rank:setString("（未上榜）")
	else
		self._ccbOwner.tf_society_rank:setString("（第"..societyRank.."名）")
	end

	self._ccbOwner.tf_my_rank:setPositionX( self._ccbOwner.tf_my_score:getPositionX() + self._ccbOwner.tf_my_score:getContentSize().width )
	self._ccbOwner.tf_society_rank:setPositionX( self._ccbOwner.tf_society_score:getPositionX() + self._ccbOwner.tf_society_score:getContentSize().width )

	-- 和时间有关的数据
	self:_updateTime()
	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end
	self._scheduler = scheduler.scheduleGlobal(function ()
		self:_updateTime()
	end, 1)

	self:checkRedTips()
end

function QUIDialogPlunderMain:checkRedTips()
	-- print("[Kumo] QUIDialogPlunderMain:checkRedTips() ", remote.plunder.isRecordRedTip)
	self._ccbOwner.sp_award_tips:setVisible(false)
	self._ccbOwner.sp_record_tips:setVisible(false)
	
	if remote.plunder:checkPersonalAwardTips() or remote.plunder:checkUnionAwardTips() then
		self._ccbOwner.sp_award_tips:setVisible(true)
	end
	if remote.plunder.isRecordRedTip then
		self._ccbOwner.sp_record_tips:setVisible(true)
	end
end

function QUIDialogPlunderMain:_updateMapBuff()
	-- buff
	self._ccbOwner.node_society_buff:setVisible(false)
	self._ccbOwner.node_society_buff_up:setVisible(false)
	self._ccbOwner.sp_society_buff_up_3:setVisible(false)
	self._ccbOwner.sp_society_buff_up_4:setVisible(false)
	self._ccbOwner.sp_society_buff_up_5:setVisible(false)

	local isBuff, member, consortiaId, consortiaName = remote.plunder:getSocietyBuffInfoByCaveId(self._caveId)
	-- print(" QUIDialogPlunderMain:_updateMapBuff()   ", isBuff, member, consortiaId, consortiaName, self._caveId)
	self._caveConsortiaId = consortiaId
	if isBuff then
		self._ccbOwner.node_society_buff:setVisible(true)
		self._ccbOwner.node_society_buff:setPositionX(0)
		-- self._ccbOwner.tf_society_name:setString(consortiaName.."（"..member.."人）")
		self._ccbOwner.tf_society_name:setString(consortiaName)
		self._ccbOwner.tf_society_buff_num:setString(member.."人")
		local width = self._ccbOwner.tf_society_name:getContentSize().width
		local x = self._ccbOwner.tf_society_name:getPositionX()
		self._ccbOwner.node_society_buff_up:setPositionX( x + width + 30)
		self._ccbOwner.node_society_buff_up:setVisible(true)
		self._ccbOwner["sp_society_buff_up_"..member]:setVisible(true)
	else
		local caveConfig = remote.plunder:getCaveConfigByCaveId( self._caveId )
		if caveConfig and caveConfig.cave_bonus == 1 then
			self._ccbOwner.node_society_buff:setVisible(true)
			self._ccbOwner.node_society_buff:setPositionX(-70)
			self._ccbOwner.tf_society_name:setString("需同宗门成员（3人及以上）狩猎本页魂兽区")
		end
	end
end

function QUIDialogPlunderMain:_updateMyOccupy()
	local myMineId = remote.plunder:getMyMineId()
	if not myMineId then 
		self._ccbOwner.node_no_mine:setVisible(true)
		self._ccbOwner.node_mine_info:setVisible(false)
		return 
	end
	self._ccbOwner.node_no_mine:setVisible(false)
	self._ccbOwner.node_mine_info:setVisible(true)

	--icon
	local mineConfig = remote.plunder:getMineConfigByMineId(myMineId)
	local quality = mineConfig.mine_quality
	local icon = QUIWidgetPlunderIcon.new({quality = quality, isNoEvent = true})
	self._ccbOwner.node_mine_icon:removeAllChildren()
	self._ccbOwner.node_mine_icon:addChild(icon)
	icon:setScale(0.5)

	-- buff
	self._ccbOwner.node_info_buff_up:setVisible(false)
	self._ccbOwner.sp_info_buff_up_3:setVisible(false)
	self._ccbOwner.sp_info_buff_up_4:setVisible(false)
	self._ccbOwner.sp_info_buff_up_5:setVisible(false)
	self._ccbOwner.node_btn_mineInfo:setPositionX(110)
	local caveConfig = remote.plunder:getCaveConfigByMineId(myMineId)
	if caveConfig and table.nums(caveConfig) > 0 then
		local isBuff, member, consortiaId, consortiaName = remote.plunder:getSocietyBuffInfoByCaveId(caveConfig.cave_id)
		-- print("[Kumo] QUIDialogPlunderMain:_updateMyOccupy() ", isBuff, member, consortiaId, consortiaName, remote.plunder:getMyConsortiaId(), self._caveId)
		if isBuff and consortiaId == remote.plunder:getMyConsortiaId() then
			self._ccbOwner.node_info_buff_up:setVisible(true)
			self._ccbOwner.tf_info_buff_num:setString(member.."人")
			self._ccbOwner.node_btn_mineInfo:setPositionX(150)
			self._ccbOwner["sp_info_buff_up_"..member]:setVisible(true)
		end
	end

end

function QUIDialogPlunderMain:_initMine()
	self:_updateMine()
end

function QUIDialogPlunderMain:_initMineIdList()
	local caveConfig = remote.plunder:getCaveConfigByCaveId( self._caveId )
	if not caveConfig or table.nums(caveConfig) == 0 then return end
	local mineIdList = string.split(caveConfig.mine_ids, ";")
	if caveConfig.cave_bonus and caveConfig.cave_bonus == 0 then
		-- QPrintTable(mineIdList)
		local mineId = mineIdList[1]
		local maxMineId = remote.plunder:getMaxMineId()
		local index = 1
		while true do
			if index > 1 then
				mineId = remote.plunder:addMineId(mineId, caveConfig.cave_id)
				if tonumber(mineId) > tonumber(maxMineId) then
					break
				end
				mineIdList[index] = mineId
			end
			index = index + 1
		end
		-- QPrintTable(mineIdList)
	else
		table.sort(mineIdList, function(a, b) return tonumber(a) < tonumber(b) end)
	end
	self._mineIdList = {}
	local startIndex = 0
	local endIndex = 0
	local isBreak = false
	local len = #mineIdList
	while true do
		local tbl = {}
		for i = 1, self._nodeCount, 1 do
			local key = startIndex + i
			if key > len then
				isBreak = true
				break
			end
			table.insert(tbl, mineIdList[key])
			endIndex = key
		end
		if table.nums(tbl) > 0 then
			table.insert(self._mineIdList, tbl)
		end
		startIndex = endIndex
		if isBreak then break end
	end
	-- QPrintTable(self._mineIdList)
	self._curPageIndex = self:_getPagrIndex()
	-- print("self._curPageIndex = ", self._curPageIndex)
end

function QUIDialogPlunderMain:_getPagrIndex( myMineId )
	local tmpId = myMineId or self._recommendMineId or self._myMineId -- 这里的顺序不能改变！！！
	local isFind = true
	if self._mineIdList and table.nums(self._mineIdList) > 0 then
		if tmpId then
			for key, ids in pairs( self._mineIdList ) do
				for _, id in pairs( ids ) do
					if tonumber(id) == tonumber(tmpId) then
						return key, isFind
					end
				end
			end

			isFind = false
		end
	end

	return 1, isFind
end

function QUIDialogPlunderMain:_updateMine()
	if self._mineIdList and table.nums(self._mineIdList) > 0 and self._curPageIndex <= table.nums(self._mineIdList) then
		local mineIdList = self._mineIdList[ self._curPageIndex ]
		if mineIdList and table.nums(mineIdList) > 0 then
			local index = 1
			while true do
				local node = self._ccbOwner["node_mine_"..index]
				if node then
					local mineId = mineIdList[index]
					-- print(" mineId = ", mineId, "tonumber :", tonumber(mineId))
					if not mineId or not tonumber(mineId) then 
						-- print("[Kumo] not mineId  index = ", index)
						node:setVisible(false)
					else
						node:setVisible(true)
						if not self._mineList[mineId] then 
							-- print("[Kumo] QUIDialogPlunderMain:_updateMine() : create ", mineId)
							local mineWdget = QUIWidgetPlunder.new({mineId = tonumber(mineId), consortiaId =  self._caveConsortiaId})
							mineWdget:addEventListener(QUIWidgetPlunder.EVENT_OK, handler(self, self._onEvent))
							mineWdget:addEventListener(QUIWidgetPlunder.EVENT_INFO, handler(self, self._onEvent))
							node:removeAllChildren()
							node:addChild(mineWdget)
							self._mineList[mineId] = mineWdget
						else
							-- print("[Kumo] QUIDialogPlunderMain:_updateMine() : (1)", mineId, "(2)", self._mineList[mineId], "(3)", table.nums(self._mineList), "(4)", self._caveConsortiaId)
							self._mineList[mineId]:update(self._caveConsortiaId)
						end
						if self._recommendMineId then
							if tonumber(mineId) == self._recommendMineId then
								-- print("[Kumo] 显示小手指")
								local recommendWidget = QUIWidgetSilverMineRecommend.new()
								recommendWidget:addEventListener(QUIWidgetSilverMineRecommend.EVENT_OK, handler(self, self._onEvent))
								recommendWidget:update( self._recommendMineId )
								self._ccbOwner.node_recommend:removeAllChildren()
								self._ccbOwner.node_recommend:addChild(recommendWidget)
								local x, y = node:getPosition()
								recommendWidget:setPosition(x, y)
							end
						else
							self._ccbOwner.node_recommend:removeAllChildren()
						end
					end
					index = index + 1
				else
					break
				end
			end
		end
	end
end

function QUIDialogPlunderMain:_updateTime()
	local timeStr, color, isActive = remote.plunder:updateTime()
	if isActive then
		self._ccbOwner.tf_time_title:setString("结束倒计时：")
		self._ccbOwner.tf_time_title:setPositionX(-112.4)
		q.autoLayerNode({self._ccbOwner.tf_time_title, self._ccbOwner.tf_countdown}, "x")
	else
		self._ccbOwner.tf_time_title:setString("极北之地已结束")
		self._ccbOwner.tf_time_title:setPositionX(3.6)
	end
	self._ccbOwner.tf_countdown:setColor( color )
	self._ccbOwner.tf_countdown:setString(timeStr)
end

function QUIDialogPlunderMain:setSilverMineDefenseHero()
	local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.PLUNDER_DEFEND_TEAM)
	local teams = nil

    local battleFormation = remote.plunder:getDefenseArmy()
    if battleFormation == nil or battleFormation.mainHeroIds == nil or #battleFormation.mainHeroIds == 0 then
    	local arenaTeamVO = remote.teamManager:getTeamByKey(remote.teamManager.ARENA_DEFEND_TEAM)
    	local teamData = arenaTeamVO:getAllTeam()
    	battleFormation = remote.teamManager:encodeBattleFormation(teamData)
    end
    teamVO:setTeamDataWithBattleFormation(battleFormation)
end

return QUIDialogPlunderMain