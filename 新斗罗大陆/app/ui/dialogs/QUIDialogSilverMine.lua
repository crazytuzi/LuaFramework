--
-- Author: Kumo.Wang
-- Date: Tue July 12 18:30:36 2016
-- 魂兽森林二级主场景
--
local QUIDialog = import(".QUIDialog")
local QUIDialogSilverMine = class("QUIDialogSilverMine", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIViewController = import("..QUIViewController")
local QSilverMineDefenseArrangement = import("...arrangement.QSilverMineDefenseArrangement")
local QChatData = import("...models.chatdata.QChatData")
local QUIWidgetChat = import("..widgets.QUIWidgetChat")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

local QUIWidgetSilverMine = import("..widgets.QUIWidgetSilverMine")
local QUIWidgetSilverMineNormal = import("..widgets.QUIWidgetSilverMineNormal")
local QUIWidgetSilverMineSenior = import("..widgets.QUIWidgetSilverMineSenior")
local QUIWidgetSilverMineIcon = import("..widgets.QUIWidgetSilverMineIcon")
local QUIWidgetSilverMineRecommend = import("..widgets.QUIWidgetSilverMineRecommend")
local QUIWidgetSilverMineName = import("..widgets.QUIWidgetSilverMineName")
local QVIPUtil = import("...utils.QVIPUtil")

local SHARE_CD_LIMIT = "%d分钟内只允许发送%d条分享，%s后可以发送"
local SHARE_CD = 5 -- 5m
local SHARE_COUNT = 5

function QUIDialogSilverMine:ctor(options)
	local ccbFile = "ccb/Dialog_SilverMine_Main.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerRule", callback = handler(self, QUIDialogSilverMine._onTriggerRule)},
		{ccbCallbackName = "onTriggerAward", callback = handler(self, QUIDialogSilverMine._onTriggerAward)},
		{ccbCallbackName = "onTriggerPlus", callback = handler(self, QUIDialogSilverMine._onTriggerPlus)},
		{ccbCallbackName = "onTriggerRank", callback = handler(self, QUIDialogSilverMine._onTriggerRank)},
        {ccbCallbackName = "onTriggerTeam", callback = handler(self, QUIDialogSilverMine._onTriggerTeam)},
        {ccbCallbackName = "onTriggerMineInfo", callback = handler(self, QUIDialogSilverMine._onTriggerMineInfo)},
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, QUIDialogSilverMine._onTriggerLeft)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, QUIDialogSilverMine._onTriggerRight)},
		{ccbCallbackName = "onTriggerAutoFind", callback = handler(self, QUIDialogSilverMine._onTriggerAutoFind)},
		{ccbCallbackName = "onTriggerChest", callback = handler(self, QUIDialogSilverMine._onTriggerChest)},
		{ccbCallbackName = "onTriggerShop", callback = handler(self, QUIDialogSilverMine._onTriggerShop)},
		{ccbCallbackName = "onTriggerShare", callback = handler(self, QUIDialogSilverMine._onTriggerShare)},
		{ccbCallbackName = "onTriggerAssist", callback = handler(self, QUIDialogSilverMine._onTriggerAssist)},
		{ccbCallbackName = "onTriggerGoldPickaxe", callback = handler(self, QUIDialogSilverMine._onTriggerGoldPickaxe)},
        {ccbCallbackName = "onTriggerClickPVP", callback = handler(self, self._onTriggerClickPVP)},  
	}

	QUIDialogSilverMine.super.ctor(self, ccbFile, callBacks, options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
 	page:setScalingVisible(false)
    page.topBar:showWithSilverMine()
    
    CalculateUIBgSize(self._ccbOwner.node_bg, 1280)

    remote.silverMine:silvermineGetMyInfoRequest()
    self._caveId = options.caveId or 1001
    self._caveRegion = options.caveRegion or remote.silverMine:getCurCaveType() or SILVERMINEWAR_TYPE.SENIOR
    remote.silverMine:setCurCaveType( self._caveRegion )
    self._recommendMineId = options.recommendMineId
    self._myMineId = options.myMineId -- 用于定位到自己的魂兽区
    self._mineList = {}
    self._mineIdList = {} -- 保存当前cave下面的mineId，以self._nodeCount分段
    self._curPageIndex = 1 -- 第几页
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

	local caveConfig = remote.silverMine:getCaveConfigByCaveRegion( self._caveRegion )
	self._firstCaveId = caveConfig[1].cave_id
	self._lastCaveId = caveConfig[table.nums(caveConfig)].cave_id

	--左下角聊天室按钮
	self.widgetChat = QUIWidgetChat.new({QUIWidgetChat.STATE_PRIVATE})
	self.widgetChat:setPosition(0, 0)
	self.widgetChat:retain()

    self._ccbOwner.tf_mine_time = setShadow5(self._ccbOwner.tf_mine_time)
    self._ccbOwner.tf_no_mine_title = setShadow5(self._ccbOwner.tf_no_mine_title)
    self._ccbOwner.tf_no_mine = setShadow5(self._ccbOwner.tf_no_mine)
    self._ccbOwner.tf_society_name_title = setShadow5(self._ccbOwner.tf_society_name_title)
    self._ccbOwner.tf_society_name = setShadow5(self._ccbOwner.tf_society_name)
    
    self._nameWidget = QUIWidgetSilverMineName.new()
	self._ccbOwner.node_name_ccb:addChild(self._nameWidget)

	self._ccbOwner.sp_share_tips:setVisible(false)
	self._ccbOwner.node_share:setVisible(false)
	
    self._pvpNodePosX = self._ccbOwner.node_pvp:getPositionX()

    self:_init()
	self:_requestInfo()
end

function QUIDialogSilverMine:_requestInfo()
	self._assistId = nil
	local isAssist = self:getOptions().isAssist
    remote.silverMine:silvermineGetCaveInfoRequest(self._caveId, function(data)
		local occupies = data.silverMineGetCaveInfoResponse.mineCave.occupies
		if isAssist and occupies then
			for i, mineInfo in pairs(occupies) do
				local assistUserInfo = mineInfo.assistUserInfo or {}
				local inviteAssistUserId = mineInfo.inviteAssistUserId or {}
				local hasAssist = false
				local myAssist = false

				-- 已经协助
				for _,info in pairs(assistUserInfo) do
					if info.userId == remote.user.userId then
						hasAssist = true
						break
					end
				end
				if not hasAssist then
					-- 被邀请协助
					for _,userId in pairs(inviteAssistUserId) do
						if userId == remote.user.userId then
							self._assistId = mineInfo.mineId
							myAssist = true
							break
						end
					end
				end
				-- 找到邀请玩家self._assistId
				if myAssist then
					break
				end
			end
		end
		if self:safeCheck() then
			self:_init()
		end
	end)
end

function QUIDialogSilverMine:viewDidAppear()
	QUIDialogSilverMine.super.viewDidAppear(self)
	
	self._ccbOwner.node_effect:setVisible(false)

	-- self._bgSound = app.sound:playSound("silvermin_sound", true)
	self._originalMusicVolume = audio.getMusicVolume()
	audio.setMusicVolume(audio.getMusicVolume() * 0.333)

    app:getNavigationManager():getController(app.mainUILayer):getTopPage().inSilverMinePage = true

	self:addBackEvent(false)
	self._silverMineProxy = cc.EventProxy.new(remote.silverMine)
    self._silverMineProxy:addEventListener(remote.silverMine.NEW_DAY, handler(self, self._updateSilverMineHandler))
    self._silverMineProxy:addEventListener(remote.silverMine.MY_INFO_UPDATE, handler(self, self._updateSilverMineHandler))
    self._silverMineProxy:addEventListener(remote.silverMine.CAVE_UPDATE, handler(self, self._updateSilverMineHandler))
    self._silverMineProxy:addEventListener(remote.silverMine.MINE_FINISH_UPDATE, handler(self, self._updateSilverMineHandler))
    self._silverMineProxy:addEventListener(remote.silverMine.BUY_GOLDPICKAXE, handler(self, self._updateSilverMineHandler))

	self._chatDataProxy = cc.EventProxy.new(app:getServerChatData())
    self._chatDataProxy:addEventListener(QChatData.NEW_MESSAGE_RECEIVED, handler(self, self._onMessageReceived))
    QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self._exitFromBattle, self)
	app:getNavigationManager():getController(app.mainUILayer):getTopPage():setChatButton(false)

    self._ccbOwner.node_chat:addChild(self.widgetChat)
    self.widgetChat:setChatAreaVisible(false)
	self.widgetChat:checkPrivateChannelRedTips()
	self.widgetChat:release()

    self:setSilverMineDefenseHero()
end

function QUIDialogSilverMine:viewAnimationInHandler()
	if remote.silverMine:getIsNeedShowAward() and remote.silverMine:checkSilverMineAwardRedTip() then
		remote.silverMine:setIsNeedShowAward( false )
		self:_onTriggerAward()
	end
end

function QUIDialogSilverMine:viewWillDisappear()
	QUIDialogSilverMine.super.viewWillDisappear(self)
    app:getNavigationManager():getController(app.mainUILayer):getTopPage().inSilverMinePage = false
	app:getNavigationManager():getController(app.mainUILayer):getTopPage():setChatButton(true)

	self:removeBackEvent()
	self._silverMineProxy:removeAllEventListeners()

	self._chatDataProxy:removeAllEventListeners()
	self._chatDataProxy = nil

	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self._exitFromBattle, self)

	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end

	-- if self._bgSound then
	-- 	app.sound:stopSound(self._bgSound)
	-- 	self._bgSound = nil
	-- end

	if self._goldPickaxeScheduler then
		scheduler.unscheduleGlobal(self._goldPickaxeScheduler)
		self._goldPickaxeScheduler = nil
	end

	audio.setMusicVolume(self._originalMusicVolume)

	remote.silverMine:setIsNeedShowMineId( 0 )
end

function QUIDialogSilverMine:gotoMine( caveId, caveRegion, mineId )
	-- print( "####", caveId, caveRegion, mineId, self._myMineId )
	if not caveId then return end
	local caveId = caveId
	if caveId == self._caveId and not mineId then
		app.tip:floatTip("魂师大人，您已在当前魂兽森林了")
		return
	end

	if caveId == self._caveId and mineId and mineId == self._myMineId then
		app.tip:floatTip("魂师大人，您已在当前魂兽森林了")
		return
	end

	if self._mineList and table.nums(self._mineList) > 0 then
		self._mineList = {}
	end
	self._caveId = caveId
	self:getOptions().caveId = self._caveId
	remote.silverMine:silvermineGetCaveInfoRequest(self._caveId, self:safeHandler(function()
			self._caveRegion = caveRegion or SILVERMINEWAR_TYPE.SENIOR
			remote.silverMine:setCurCaveType( self._caveRegion )
			self._myMineId = mineId
		    self._curPageIndex = 1
		    -- print("[Kumo] 清除小手指")
		    self._recommendMineId = nil
		    self:_init()
		end))
end

function QUIDialogSilverMine:_updateSilverMineHandler( event )
	if event.name == remote.silverMine.NEW_DAY then
		self:_updateInfo()
	elseif event.name == remote.silverMine.MY_INFO_UPDATE then
		self:_updateMine()
		self:_updateInfo()
		self:_updateMyOccupy()
	elseif event.name == remote.silverMine.CAVE_UPDATE then
		self:_updateMapBuff()
		self:_updateMine()
		self:_updateInfo()
		self:_updateMyOccupy()
	elseif event.name == remote.silverMine.MINE_FINISH_UPDATE then
		local finishMineId = remote.silverMine:getFinishMineId()
		if finishMineId and finishMineId ~= 0 then
			remote.silverMine:addAniLock()
			self:_showAwardAnimation( finishMineId )
		else
		    self:_request()
		end
	elseif event.name == remote.silverMine.BUY_GOLDPICKAXE then
		self._ccbOwner.sp_goldPickaxe_tips:setVisible(false)
	end
end

function QUIDialogSilverMine:_showAwardAnimation( mineId )
	local mineIdList = self._mineIdList[ self._curPageIndex ] or {}
	local curCave = 0
	for i = 1, table.nums(mineIdList), 1 do
		if mineId == tonumber(mineIdList[i]) then
			curCave = i
			break
		end
	end
	if curCave == 0 then
		return
	end

	-- 找到世界坐标
	local srcPos = self._ccbOwner["node_mine_"..curCave]:convertToWorldSpace(ccp(-display.width/2, -display.height/2))
	local dstPos = self._ccbOwner.btn_report:convertToWorldSpace(ccp(-display.width/2, -display.height/2))
	dstPos.x = dstPos.x + 40
	dstPos.y = dstPos.y + 40
	local ccbFile = "effects/yinkuangzhan_tiaodong.ccbi"
	local aniPlayer = QUIWidgetAnimationPlayer.new()
    self._ccbOwner.node_ani:addChild(aniPlayer)
    aniPlayer:playAnimation(ccbFile, function()
			self:_request()
    	end, function()
    		remote.silverMine:setFinishMineId( 0 )
			remote.silverMine:removeAniLock()
		end, true)
	local ccbOwner = aniPlayer._ccbOwner
    ccbOwner.node_src:setPosition(srcPos)
    ccbOwner.node_dst:setPosition(dstPos)

	local count = ccbOwner.node_src:getChildrenCount()
	local sprites = {}
	for index = 0, count-1 do
		local sprite = tolua.cast(ccbOwner.node_src:getChildren():objectAtIndex(index), "CCSprite")
		sprites[#sprites+1] = sprite
	end
	local posX = dstPos.x - srcPos.x
	local posY = dstPos.y - srcPos.y
	for index, sprite in ipairs(sprites) do
		local arr = CCArray:create()
	    arr:addObject(CCDelayTime:create(0.05*index))
	    arr:addObject(CCMoveTo:create(0.1*index, ccp(posX, posY)))
	    arr:addObject(CCFadeOut:create(0.2))
		sprite:runAction(CCSequence:create(arr))
	end
end

function QUIDialogSilverMine:_onMessageReceived(event)
	self.widgetChat:checkPrivateChannelRedTips()
end

function QUIDialogSilverMine:_request()
	remote.silverMine:silvermineGetMyInfoRequest()
	if self._caveId then
		remote.silverMine:silvermineGetCaveInfoRequest(self._caveId)
	end
end

function QUIDialogSilverMine:onTriggerBackHandler()
	if remote.silverMine:isLock() or remote.silverMine:isAniLock() then return end
    remote.silverMine:addLock()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogSilverMine:_onTriggerRule()
	app.sound:playSound("common_small")
	if remote.silverMine:isLock() or remote.silverMine:isAniLock() then return end
    remote.silverMine:addLock()
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilverMineRule"})
end

function QUIDialogSilverMine:_onTriggerAward(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_report) == false then return end
	app.sound:playSound("common_small")
	if remote.silverMine:isLock() or remote.silverMine:isAniLock() then return end
    remote.silverMine:addLock()
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass= "QUIDialogSilverMineAwardAndRecord", options = {caveRegion = self._caveRegion}})
end

function QUIDialogSilverMine:_onTriggerPlus(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_plus) == false then return end
	app.sound:playSound("common_small")
	if remote.silverMine:isLock() or remote.silverMine:isAniLock() then return end
    remote.silverMine:addLock()
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCountBase",
		options = {cls = "QBuyCountSilverMine"}})
end

function QUIDialogSilverMine:_onTriggerRank()
	app.sound:playSound("common_small")
	if remote.silverMine:isLock() or remote.silverMine:isAniLock() then return end
    remote.silverMine:addLock()
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRank", options = {initRank = "sliverMine"}}, {isPopCurrentDialog = false})
end

function QUIDialogSilverMine:_onTriggerChest()
	app.sound:playSound("common_small")
	if remote.silverMine:isLock() or remote.silverMine:isAniLock() then return end
    remote.silverMine:addLock()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMall", options = {tab = "GEMSTONE_TYPE"}})
end

function QUIDialogSilverMine:_onTriggerShop()
	app.sound:playSound("common_small")
	if remote.silverMine:isLock() or remote.silverMine:isAniLock() then return end
    remote.silverMine:addLock()
    remote.stores:openShopDialog(SHOP_ID.silverShop)
end

function QUIDialogSilverMine:_onTriggerLeft()
	app.sound:playSound("common_small")
	if remote.silverMine:isLockByTime() or remote.silverMine:isAniLock() then return end
    remote.silverMine:addLockByTime()
 	if self._curPageIndex == 1 then
 		self._caveId = self._caveId - 1
 		self:getOptions().caveId = self._caveId
 		if  self._mineList and table.nums(self._mineList) > 0 then
			self._mineList = {}
		end
 		remote.silverMine:silvermineGetCaveInfoRequest(self._caveId)
 		self:_initMineIdList()
 		self._curPageIndex = table.nums(self._mineIdList)
	else
		self._curPageIndex = self._curPageIndex - 1
		if  self._mineList and table.nums(self._mineList) > 0 then
			self._mineList = {}
		end
	end
	-- print("[Kumo] 清除小手指")
	self._recommendMineId = nil
	self._myMineId = nil
	remote.silverMine:setIsNeedShowMineId( 0 )
	self:_updateMapBuff()
	self:_updateMine()
	self:_updateInfo()
	self:_updateBtnState()
end

function QUIDialogSilverMine:_onTriggerRight()
	app.sound:playSound("common_small")
	if remote.silverMine:isLockByTime() or remote.silverMine:isAniLock() then return end
    remote.silverMine:addLockByTime()
	if self._curPageIndex == table.nums(self._mineIdList) then
		self._caveId = self._caveId + 1
		self:getOptions().caveId = self._caveId
		if  self._mineList and table.nums(self._mineList) > 0 then
			self._mineList = {}
		end
		remote.silverMine:silvermineGetCaveInfoRequest(self._caveId)
 		self:_initMineIdList()
 		self._curPageIndex = 1
	else
		self._curPageIndex = self._curPageIndex + 1
		if  self._mineList and table.nums(self._mineList) > 0 then
			self._mineList = {}
		end
	end
	-- print("[Kumo] 清除小手指")
	self._recommendMineId = nil
	self._myMineId = nil
	remote.silverMine:setIsNeedShowMineId( 0 )
	self:_updateMapBuff()
	self:_updateMine()
	self:_updateInfo()
	self:_updateBtnState()
end

function QUIDialogSilverMine:_onTriggerAutoFind(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_auto_find) == false then return end
	app.sound:playSound("common_small")
	if remote.silverMine:isLock() or remote.silverMine:isAniLock() then return end
    remote.silverMine:addLock()
	remote.silverMine:silvermineQuickFindMineRequest(self:safeHandler(function(response)
			local caveId = response.silverMineQuickFindMineResponse.caveId
			local recommendMineId = response.silverMineQuickFindMineResponse.mineId
			local caveConfig = remote.silverMine:getCaveConfigByCaveId(caveId)
			-- local mineConfig = remote.silverMine:getMineConfigByMineId(recommendMineId)
			if caveConfig and table.nums(caveConfig) > 0 then
				local myOccupy = remote.silverMine:getMyOccupy()
				if myOccupy and table.nums(myOccupy) > 0 then
					-- 自己有魂兽区的时候，需要判断找到的新魂兽区是不是比自己的好
					-- local myMine = remote.silverMine:getMineConfigByMineId( myOccupy.mineId )
					-- if myMine.mine_quality == SILVERMINE_TYPE.DIAMOND then
					-- 	app.tip:floatTip("魂师大人，当前您所狩猎的魂兽区已经是最高品质了")
					-- 	return
					-- elseif mineConfig.mine_quality <= myMine.mine_quality then
					-- 	app.tip:floatTip("魂师大人，当前未找到比您所狩猎品质更高的魂兽区，请稍后再试试吧")
					-- 	return
					-- end
					if myOccupy.mineId == recommendMineId then
						app.tip:floatTip("魂师大人，未找到比您当前所狩猎收益更高的魂兽区，建议稍后再试试哦~")
						return
					end
				end

				if self._recommendMineId == recommendMineId then 
					remote.silverMine:removeLock()
					app.tip:floatTip("魂师大人~已为您找到最佳的魂兽区啦~")
					return 
				end
				if self._caveId ~= caveConfig.cave_id then
					if  self._mineList and table.nums(self._mineList) > 0 then
						self._mineList = {}
					end
				end
				self._caveId = caveConfig.cave_id or 1001
				self:getOptions().caveId = self._caveId
				remote.silverMine:silvermineGetCaveInfoRequest(self._caveId, self:safeHandler(function()
					self._caveRegion = caveConfig.cave_region or SILVERMINEWAR_TYPE.SENIOR
					remote.silverMine:setCurCaveType( self._caveRegion )
					-- print("[Kumo] 需要小手指")
					self._recommendMineId = recommendMineId
				    self._curPageIndex = 1
				    self:_init()
				end))
			end
		end))
end

function QUIDialogSilverMine:_onTriggerShare(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_share) == false then return end
	app.sound:playSound("common_small")
	remote.silverMine:setIsShareRedTips( false )
	self._ccbOwner.sp_share_tips:setVisible(false)
	local earliestTime, replayCount = app:getServerChatData():getEarliestReplaySilverMineSentTime()
	if replayCount >= SHARE_COUNT and q.serverTime() - earliestTime < SHARE_CD * 60 then
		app.tip:floatTip(string.format(SHARE_CD_LIMIT, SHARE_CD, SHARE_COUNT, q.timeToHourMinuteSecond(SHARE_CD * 60 - (q.serverTime() - earliestTime), true)))
		return
	end

	local caveConfig = remote.silverMine:getCaveConfigByCaveId( self._caveId )
	local myConsortiaId = remote.silverMine:getMyConsortiaId() 
	if caveConfig.cave_bonus == 1 and myConsortiaId and myConsortiaId ~= "" then
		app:alert({content = "魂师大人，是否要共享魂兽森林信息至宗门频道，便于同宗门成员一起来狩猎并激活宗门加成？", title = "系统提示", 
                callback = function(state)
                    if state == ALERT_TYPE.CONFIRM then
                        local msg = string.format("##n我在##e《%s》##n，大家快来一起狩猎，超过三个有宗门加成哦", caveConfig.cave_name or "")
						app:getServerChatData():sendMessage(msg, 2, nil, nil, nil, {caveId = self._caveId, caveRegion = caveConfig.cave_region, caveName = caveConfig.cave_name},
							function( code )
								if code  and code == 0 then
									app.tip:floatTip("魂师大人，已将分享魂兽森林信息至宗门频道啦")
									app:getServerChatData():setEarliestReplaySilverMineSentTime(q.serverTime())
								end
							end
						)
                    end
                end, isAnimation = false}, true, true)
	end
end

--协助邀请
function QUIDialogSilverMine:_onTriggerAssist(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_assist) == false then return end
	app.sound:playSound("common_small")
	local myConsortiaId = remote.silverMine:getMyConsortiaId() 
	if myConsortiaId and myConsortiaId ~= "" then
		remote.silverMine:silverMineGetInviteListRequest(function (data)
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSilverMineAssist",
				options = {fighters = data.silverMineGetInviteListResponse.consortiaMemberList}})
		end)
	else
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSilverMineAssist",
			options = {fighters = {}}})
	end
end

-- 诱魂草
function QUIDialogSilverMine:_onTriggerGoldPickaxe()
	app.sound:playSound("common_small")
	remote.flag:set(remote.flag.FLAG_FRIST_GOLDPICKAXE, 1)
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilverBuyVirtual"})
	self._ccbOwner.node_effect:setVisible(false)
	remote.silverMine:setIsFirstGoldPickaxe(false)
	self._ccbOwner.sp_goldPickaxe_tips:setVisible(false)
end

function QUIDialogSilverMine:_onTriggerTeam(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_team) == false then return end
	app.sound:playSound("common_small")
	if remote.silverMine:isLock() or remote.silverMine:isAniLock() then return end
    remote.silverMine:addLock()
	local silverMineDefenseArrangement = QSilverMineDefenseArrangement.new({teamKey = remote.teamManager.SILVERMINE_DEFEND_TEAM})
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement",
		options = {arrangement = silverMineDefenseArrangement, isBattle = true}})
end

function QUIDialogSilverMine:_onTriggerMineInfo(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_mine_info) == false then return end
	app.sound:playSound("common_small")
	if remote.silverMine:isLock() or remote.silverMine:isAniLock() then return end
    remote.silverMine:addLock()
	if not self._hasMyOccupy then return end
	local myOccupy = remote.silverMine:getMyOccupy()
	local myMineId = myOccupy.mineId
	local pageIndex, isFind = self:_getPagrIndex( myMineId )
	local caveConfig = remote.silverMine:getCaveConfigByMineId(myMineId)
	if caveConfig and caveConfig.cave_id and caveConfig.cave_id == self._caveId and pageIndex == self._curPageIndex and isFind then
		app.tip:floatTip("魂师大人，您已在当前魂兽森林了")
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
		remote.silverMine:silvermineGetCaveInfoRequest(self._caveId, self:safeHandler(function()
				self._caveRegion = caveConfig.cave_region or SILVERMINEWAR_TYPE.SENIOR
				remote.silverMine:setCurCaveType( self._caveRegion )
			    self._myMineId = myMineId
			    -- print("[Kumo] 清除小手指")
			    self._recommendMineId = nil
			    self:_init()
			end))
	end
end

function QUIDialogSilverMine:_onTriggerClickPVP(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_pvp) == false then return end
    app.sound:playSound("common_small")

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPVPPropTip", 
        options = {teamKey = remote.teamManager.SILVERMINE_DEFEND_TEAM}}, {isPopCurrentDialog = false})
end

function QUIDialogSilverMine:_exitFromBattle()
	while true do
		local dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
		-- print("[Kumo] dialog = ", dialog)
		-- if dialog then
		-- 	print("[Kumo] dialog = ", dialog.__cname)
		-- end
		if dialog and dialog.__cname == "QUIDialogSilverMineMineInfo" then
			-- print("[Kumo] 删除 QUIDialogSilverMineMineInfo")
			-- app.tip:floatTip("发现残留的QUIDialogSilverMineMineInfo界面，强制删除成功")
			app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
		else
			break
		end
	end
	self:_request()
	self:_updateMapBuff()
	self:_updateMine()
	self:_updateInfo()
	self:_updateMyOccupy()
	if remote.silverMine:getIsShareRedTips() then
		local earliestTime, replayCount = app:getServerChatData():getEarliestReplaySilverMineSentTime()
		-- if not (replayCount >= SHARE_COUNT and q.serverTime() - earliestTime < SHARE_CD * 60) then
		-- 	self._ccbOwner.sp_share_tips:setVisible(true)
		-- end
	end

	if remote.silverMine:getIsLevelUp() then
        remote.silverMine:setIsLevelUp( false )
        local callBack = nil
        if remote.silverMine:getIsNeedShowMineId() > 0 then
        	callBack = handler(self, self._showMyMineAppear)
        end
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSilverMineLevelUp", options = {callBack = callBack}}, {isPopCurrentDialog = false} )
    else
    	if remote.silverMine:getIsNeedShowMineId() > 0 then
        	self:_showMyMineAppear()
        end
    end
end

function QUIDialogSilverMine:_showMyMineAppear()
	for _, mineWidget in pairs(self._mineList) do
		mineWidget:show()
	end
end

function QUIDialogSilverMine:_onEvent(event)
	-- print("[Kumo] QUIDialogSilverMine:_onEvent() ", event.name, event.mineId)
	app.sound:playSound("common_small")
	if event.name == QUIWidgetSilverMine.EVENT_OK or event.name == QUIWidgetSilverMineRecommend.EVENT_OK then
		-- print("[Kumo] 清除小手指")
		self._ccbOwner.node_recommend:removeAllChildren()
		self._recommendMineId = nil
		self:getOptions().recommendMineId = nil
		self._myMineId = event.mineId
		self:getOptions().myMineId = event.mineId
		-- print("[Kumo] 警告！ 弹出QUIDialogSilverMineMineInfo界面")
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSilverMineMineInfo", options = {mineId = event.mineId}})
	elseif event.name == QUIWidgetSilverMine.EVENT_INFO then
		remote.silverMine:silvermineShowDefenseArmyRequest(event.mineId, function(response)
				local data = response.silverMineShowDefenseArmyResponse.defender
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo", 
					options = {fighter = data, forceTitle = "防守战力：", isPVP = true}}, {isPopCurrentDialog = false})
			end)
	end
end

function QUIDialogSilverMine:_init()
	remote.silverMine:setIsNeedShowChangeAni(false)
	self:_initMineIdList()
	self:_updateBtnState()
	self:_initInfo()
	self:_initMine()
end

function QUIDialogSilverMine:_updateBtnState()
	local caveConfig = remote.silverMine:getCaveConfigByCaveRegion( self._caveRegion or remote.silverMine:getCurCaveType() or SILVERMINEWAR_TYPE.SENIOR )
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

function QUIDialogSilverMine:_initInfo()
	self:_updateMap()
	self:_updateInfo()
	self:_updateMyOccupy()
	self:_updateMapBuff()
end

function QUIDialogSilverMine:_updateMap()
	local bg = nil
	if not self._caveRegion then
		self._caveRegion = remote.silverMine:getCurCaveType() or SILVERMINEWAR_TYPE.SENIOR
	end
	if self._caveRegion == SILVERMINEWAR_TYPE.SENIOR then
		bg = QUIWidgetSilverMineSenior.new()
	else
		bg = QUIWidgetSilverMineNormal.new()
	end
	self._ccbOwner.node_bg:removeAllChildren()
	self._ccbOwner.node_bg:addChild(bg)
end

function QUIDialogSilverMine:_updateInfo()
	-- 奖励小红点
	if remote.silverMine:checkSilverMineAwardRedTip() or remote.silverMine:getIsRecordRedTip()  then
		self._ccbOwner.sp_award_tips:setVisible(true)
	else
		self._ccbOwner.sp_award_tips:setVisible(false)
	end
	-- 商店小红点
	if remote.silverMine:checkSilverMineShopRedTip() then
		self._ccbOwner.sp_shop_tips:setVisible(true)
	else
		self._ccbOwner.sp_shop_tips:setVisible(false)
	end
	-- 分享按钮的小红点
	if remote.silverMine:getIsShareRedTips() then
		local earliestTime, replayCount = app:getServerChatData():getEarliestReplaySilverMineSentTime()
		-- if not (replayCount >= SHARE_COUNT and q.serverTime() - earliestTime < SHARE_CD * 60) then
		-- 	self._ccbOwner.sp_share_tips:setVisible(true)
		-- end
	end
	-- 诱魂草小红点
	if remote.silverMine:checkSilverMineGoldPickaxeRedTip() then
		self._ccbOwner.sp_goldPickaxe_tips:setVisible(true)
	else
		self._ccbOwner.sp_goldPickaxe_tips:setVisible(false)
	end

	local itemInfo
	local shopItems = remote.stores:getStoresById(SHOP_ID.itemShop)
	if shopItems ~= nil then
		for i, v in pairs(shopItems) do
			if v.id == GEMSTONE_SHOP_ID then
				itemInfo = v
				break
			end
		end
	end
	self._ccbOwner.tf_sale:setVisible(false)
	self._ccbOwner.sp_chest_tips:setVisible(false)
	if itemInfo ~= nil then
		local chestSale = remote.stores:getSaleByShopItemInfo(itemInfo, true)
		if chestSale == 0 then
			self._ccbOwner.sp_chest_tips:setVisible(true)
		elseif chestSale <= 1.7 then
			self._ccbOwner.tf_sale:setVisible(true)
			self._ccbOwner.tf_sale:setString(chestSale.."折")
		end
	end
	
	local caveConfig = remote.silverMine:getCaveConfigByCaveId( self._caveId )
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
			self._ccbOwner.node_share:setPositionX(300)
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
			self._ccbOwner.node_share:setPositionX(220)
		end
	end

	local myConsortiaId = remote.silverMine:getMyConsortiaId()
	if not myConsortiaId or myConsortiaId == "" or caveConfig == nil or not caveConfig.cave_bonus or caveConfig.cave_bonus == 0 then
		self._ccbOwner.node_share:setVisible(false)
	else
		self._ccbOwner.node_share:setVisible(true)
	end
	
	local count = remote.silverMine:getFightCount()
	self._ccbOwner.tf_attack_count:setString(count)

	local totalVIPNum = QVIPUtil:getCountByWordField("silvermine_limit", QVIPUtil:getMaxLevel())
	local totalNum = QVIPUtil:getCountByWordField("silvermine_limit")	
	if totalVIPNum > totalNum or totalNum > remote.silverMine:getBuyFightCount() then
		self._ccbOwner.btn_plus:setVisible(true)
		self._ccbOwner.btn_plus:setEnabled(true)
		self._ccbOwner.btn_plus_expand:setEnabled(true)
	else
		self._ccbOwner.btn_plus:setVisible(false)
		self._ccbOwner.btn_plus:setEnabled(false)
		self._ccbOwner.btn_plus_expand:setEnabled(false)
	end
	-- local force = remote.silverMine:getDefenseForce()
	local force = remote.teamManager:getBattleForceForAllTeam(remote.teamManager.SILVERMINE_DEFEND_TEAM, false)
	local fontInfo = db:getForceColorByForce(tonumber(force),true)
	local forceNum, forceUnit = q.convertLargerNumber(force)
	self._ccbOwner.tf_defens_force:setString(forceNum..(forceUnit or ""))
	local color = string.split(fontInfo.force_color, ";")
	self._ccbOwner.tf_defens_force:setColor(ccc3(color[1], color[2], color[3]))

	self._ccbOwner.node_pvp:setVisible(ENABLE_PVP_FORCE)
	self._ccbOwner.node_pvp:setPositionX( self._pvpNodePosX + self._ccbOwner.tf_defens_force:getContentSize().width)
	
	self._ccbOwner.sp_team_tips:setVisible(not remote.teamManager:checkTeamStormIsFull(remote.teamManager.SILVERMINE_DEFEND_TEAM))

	if self._goldPickaxeScheduler then
		scheduler.unscheduleGlobal(self._goldPickaxeScheduler)
		self._goldPickaxeScheduler = nil
	end
	self:_updateGoldPickaxeTime()
	self._goldPickaxeScheduler = scheduler.scheduleGlobal(self:safeHandler(function() 
			self:_updateGoldPickaxeTime()
		end), 1)

	remote.flag:get({remote.flag.FLAG_FRIST_GOLDPICKAXE}, function (tbl)
				if tbl[remote.flag.FLAG_FRIST_GOLDPICKAXE] == "" then
					self._ccbOwner.node_effect:setVisible(true)
				end
			end)
end

function QUIDialogSilverMine:_updateMapBuff()
	-- buff
	self._ccbOwner.node_society_buff:setVisible(false)
	self._ccbOwner.node_society_buff_up:setVisible(false)
	self._ccbOwner.sp_society_buff_up_3:setVisible(false)
	self._ccbOwner.sp_society_buff_up_4:setVisible(false)
	self._ccbOwner.sp_society_buff_up_5:setVisible(false)
	self._ccbOwner.tf_society_buff_num:setString("")
	
	local isBuff, member, consortiaId, consortiaName = remote.silverMine:getSocietyBuffInfoByCaveId(self._caveId)
	self._caveConsortiaId = consortiaId
	if isBuff then
		self._ccbOwner.node_society_buff:setVisible(true)
		self._ccbOwner.node_society_buff:setPositionX(0)
		self._ccbOwner.tf_society_name:setString(consortiaName)
		if member == 3 then
			self._ccbOwner.tf_society_buff_num:setString("（"..member.."人占领：产量小幅加成）")
		elseif member == 4 then
			self._ccbOwner.tf_society_buff_num:setString("（"..member.."人占领：产量大幅加成）")
		elseif member == 5 then
			self._ccbOwner.tf_society_buff_num:setString("（"..member.."人占领：产量巨幅加成）")
		end

		local posX = self._ccbOwner.tf_society_name:getPositionX()
		local nameWidth = self._ccbOwner.tf_society_name:getContentSize().width
		local numWidth = self._ccbOwner.tf_society_buff_num:getContentSize().width
		self._ccbOwner.tf_society_buff_num:setPositionX( posX + nameWidth + 5)
		self._ccbOwner.node_society_buff_up:setPositionX( posX + nameWidth + numWidth-5)
		self._ccbOwner.node_society_buff_up:setVisible(true)
		self._ccbOwner["sp_society_buff_up_"..member]:setVisible(true)
	else
		local caveConfig = remote.silverMine:getCaveConfigByCaveId( self._caveId )
		if caveConfig and caveConfig.cave_bonus == 1 then
			self._ccbOwner.node_society_buff:setVisible(true)
			self._ccbOwner.node_society_buff:setPositionX(-70)
			self._ccbOwner.tf_society_name:setString("需同宗门成员（3人及以上）狩猎本页魂兽区")
		end
	end
end

function QUIDialogSilverMine:_updateMyOccupy()
	local myOccupy = remote.silverMine:getMyOccupy()
	if not myOccupy or table.nums(myOccupy) == 0 then 
		self._ccbOwner.node_assist:setVisible(false)
		-- print("[Kumo] _updateMyOccupy() 没有狩猎")
		self._isOvertime = false
		self._hasMyOccupy = false
		self._ccbOwner.node_no_mine:setVisible(true)
		self._ccbOwner.node_mine_info:setVisible(false)
		if remote.silverMine:getFightCount() > 0 then
			self._ccbOwner.sp_autoFind_tips:setVisible(true)
		end
		return 
	end
	--显示邀请协助按钮
	self._ccbOwner.node_assist:setVisible(true)
	self._ccbOwner.sp_assist_tips:setVisible(remote.silverMine:checkSilverMineAssistRedTip())

	self._ccbOwner.sp_autoFind_tips:setVisible(false)
	self._isOvertime = false
	self._hasMyOccupy = true
	self._ccbOwner.node_no_mine:setVisible(false)
	self._ccbOwner.node_mine_info:setVisible(true)

	local myMineId = myOccupy.mineId
	local startTime = myOccupy.startAt
	local endTime = myOccupy.endAt

	--icon
	local mineConfig = remote.silverMine:getMineConfigByMineId(myMineId)
	local quality = mineConfig.mine_quality
	local icon = QUIWidgetSilverMineIcon.new({quality = quality, isNoEvent = true})
	self._ccbOwner.node_mine_icon:removeAllChildren()
	self._ccbOwner.node_mine_icon:addChild(icon)
	icon:setScale(0.5)

	-- buff
	self._ccbOwner.node_info_buff_up:setVisible(false)
	self._ccbOwner.sp_info_buff_up_3:setVisible(false)
	self._ccbOwner.sp_info_buff_up_4:setVisible(false)
	self._ccbOwner.sp_info_buff_up_5:setVisible(false)
	self._ccbOwner.node_time:setPositionX(-40)
	local caveConfig = remote.silverMine:getCaveConfigByMineId(myMineId)
	if caveConfig and table.nums(caveConfig) > 0 then
		local isBuff, member, consortiaId, consortiaName = remote.silverMine:getSocietyBuffInfoByCaveId(caveConfig.cave_id)
		-- print("[Kumo] QUIDialogSilverMine:_updateMyOccupy() ", isBuff, member, consortiaId, consortiaName, remote.silverMine:getMyConsortiaId(), self._caveId)
		if isBuff and consortiaId == remote.silverMine:getMyConsortiaId() then
			self._ccbOwner.node_info_buff_up:setVisible(true)
			self._ccbOwner.tf_info_buff_num:setString(member.."人")
			self._ccbOwner.node_time:setPositionX(0)
			self._ccbOwner["sp_info_buff_up_"..member]:setVisible(true)
		end
	end
	
	-- 和时间有关的数据
	self:_updateTime()
	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end
	self._scheduler = scheduler.scheduleGlobal(function ()
		self:_updateTime()
	end, 1)
end

function QUIDialogSilverMine:_initMine()
	self:_updateMine()
end

function QUIDialogSilverMine:_initMineIdList()
	local caveConfig = remote.silverMine:getCaveConfigByCaveId( self._caveId )
	if not caveConfig or table.nums(caveConfig) == 0 then return end
	local mineIdList = string.split(caveConfig.mine_ids, ";")
	table.sort(mineIdList, function(a, b) return tonumber(a) < tonumber(b) end)
	self._mineIdList = {}
	local startIndex = 0
	local endIndex = 0
	local isBreak = false
	while true do
		local tbl = {}
		for i = 1, self._nodeCount, 1 do
			local key = startIndex + i
			if key > table.nums(mineIdList) then
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

function QUIDialogSilverMine:_getPagrIndex( myMineId )
	--print("[Kumo] QUIDialogSilverMine:_getPagrIndex() ", myMineId, self._myMineId)
	local tmpId = myMineId or self._myMineId or self._recommendMineId or self._assistId
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

function QUIDialogSilverMine:_updateMine()
	-- print("[Kumo] QUIDialogSilverMine:_updateMine() ")
	-- if  self._mineList and table.nums(self._mineList) > 0 then
	-- 	self._mineList = {}
	-- end

	if self._mineIdList and table.nums(self._mineIdList) > 0 and self._curPageIndex <= table.nums(self._mineIdList) then
		local mineIdList = self._mineIdList[ self._curPageIndex ]
		if mineIdList and table.nums(mineIdList) > 0 then
			local index = 1
			while true do
				local node = self._ccbOwner["node_mine_"..index]
				if node then
					local mineId = mineIdList[index]
					-- print("mineId = ", mineId)
					if not self._mineList[mineId] then 
						-- print("[Kumo] QUIDialogSilverMine:_updateMine() ", self._caveConsortiaId)
						local mineWdget = QUIWidgetSilverMine.new({mineId = tonumber(mineId), consortiaId =  self._caveConsortiaId})
						mineWdget:addEventListener(QUIWidgetSilverMine.EVENT_OK, handler(self, self._onEvent))
						mineWdget:addEventListener(QUIWidgetSilverMine.EVENT_INFO, handler(self, self._onEvent))
						-- mineWdget:addEventListener(QUIWidgetSilverMine.EVENT_ASSIST, handler(self, self._onEvent))
						node:removeAllChildren()
						node:addChild(mineWdget)
						self._mineList[mineId] = mineWdget
					else
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

					index = index + 1
				else
					break
				end
			end
		end
	end
end

function QUIDialogSilverMine:_updateTime()
	if not self._hasMyOccupy then
		-- print("[Kumo] _updateTime() 没有狩猎")
		self._isOvertime = false
		self._ccbOwner.node_no_mine:setVisible(true)
		self._ccbOwner.node_mine_info:setVisible(false)
		if self._scheduler then
			scheduler.unscheduleGlobal(self._scheduler)
			self._scheduler = nil
		end
	end

	local isOvertime, timeStr, color = remote.silverMine:updateTime( true, nil )
	self._ccbOwner.tf_mine_time:setColor( color )

	if isOvertime then
		-- print("[Kumo] _updateTime() 过时了")
		self._isOvertime = true
		self._ccbOwner.tf_mine_time:setString("结算中")

		local myOccupy = remote.silverMine:getMyOccupy()
		if not myOccupy or table.nums(myOccupy) == 0 then 
			-- print("[Kumo] _updateTime() 没有狩猎")
			self._isOvertime = false
			self._hasMyOccupy = false
			self._ccbOwner.node_no_mine:setVisible(true)
			self._ccbOwner.node_mine_info:setVisible(false)
		end

		return
	end
	self._ccbOwner.tf_mine_time:setString(timeStr)
end

function QUIDialogSilverMine:_updateGoldPickaxeTime()
	local isOvertime, timeStr, color = remote.silverMine:updateGoldPickaxeTime(true)
	if isOvertime then
		-- self._ccbOwner.tf_goldPickaxe_time:setString("00:00:00")
		self._ccbOwner.tf_goldPickaxe_time:setString("")
	else
		self._ccbOwner.tf_goldPickaxe_time:setString(timeStr)
	end
	self._ccbOwner.tf_goldPickaxe_time:setColor( color )
end

function QUIDialogSilverMine:setSilverMineDefenseHero()
	local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.SILVERMINE_DEFEND_TEAM)
	local teams = nil

    local battleFormation = remote.plunder:getDefenseArmy()
    if battleFormation == nil or battleFormation.mainHeroIds == nil or #battleFormation.mainHeroIds == 0 then
    	local arenaTeamVO = remote.teamManager:getTeamByKey(remote.teamManager.ARENA_DEFEND_TEAM)
    	local teamData = arenaTeamVO:getAllTeam()
    	battleFormation = remote.teamManager:encodeBattleFormation(teamData)
    end
    teamVO:setTeamDataWithBattleFormation(battleFormation)
end

return QUIDialogSilverMine