

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMetalAbyssMain = class("QUIDialogMetalAbyssMain", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetMetalAbyssFighterInfo = import("..widgets.QUIWidgetMetalAbyssFighterInfo")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")
local QMetalAbyssArrangement = import("...arrangement.QMetalAbyssArrangement")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QQuickWay = import("...utils.QQuickWay")

QUIDialogMetalAbyssMain.RESET_TIPS = "重置次数不足，无法重置"


QUIDialogMetalAbyssMain.CUR_STAGE_STATE =
{
	INIT_STATE = 0 ,-- 初始未激活状态
	COMPLETE_STATE = 1 ,-- 已完成状态（显示需要往下一层）
	INVALID_STATE = 2 ,-- 无效状态
}


function QUIDialogMetalAbyssMain:ctor(options)
	local ccbFile = "ccb/Dialog_MetalAbyss_Main.ccbi"
	local callBacks = {
		{ccbCallbackName = "onPressNormalPrize", callback = handler(self, self._onPressNormalPrize)},
		{ccbCallbackName = "onPressFinalPirze", callback = handler(self, self._onPressFinalPirze)},
		{ccbCallbackName = "onTriggerRule", callback = handler(self, self._onTriggerRule)},
		{ccbCallbackName = "onTriggerRank", callback = handler(self, self._onTriggerRank)},
		{ccbCallbackName = "onTriggerRefresh", callback = handler(self, self._onTriggerRefresh)},
		{ccbCallbackName = "onTriggerRewardTips", callback = handler(self, self._onTriggerRewardTips)},
		-- {ccbCallbackName = "onTriggerTouch", callback = handler(self, self._onTriggerTouch)},
		{ccbCallbackName = "onTriggerReset", callback = handler(self, self._onTriggerReset)},
		{ccbCallbackName = "onPressGotoNext", callback = handler(self, self._onPressGotoNext)},
		{ccbCallbackName = "onTriggerStartSearch", callback = handler(self, self._onTriggerStartSearch)},
		{ccbCallbackName = "onTriggerStore", callback = handler(self, self._onTriggerStore)},
		{ccbCallbackName = "onTriggerRewardPerview", callback = handler(self, self._onTriggerRewardPerview)},

	}
    QUIDialogMetalAbyssMain.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = false 
    
    CalculateUIBgSize(self._ccbOwner.sp_bg_mid)
    CalculateUIBgSize(self._ccbOwner.sp_bg_end)
    CalculateUIBgSize(self._ccbOwner.sp_bg_start)
    CalculateUIBgSize(self._ccbOwner.node_action,1024)
    CalculateUIBgSize(self._ccbOwner.node_particle,1024)
    self._ccbOwner.node_action:setScale(display.width / 640)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    q.setButtonEnableShadow(self._ccbOwner.btn_reset)
    q.setButtonEnableShadow(self._ccbOwner.btn_reward_tips)
    q.setButtonEnableShadow(self._ccbOwner.btn_refresh)
    q.setButtonEnableShadow(self._ccbOwner.btn_rank)
    q.setButtonEnableShadow(self._ccbOwner.btn_rule)
    q.setButtonEnableShadow(self._ccbOwner.btn_shop)
    q.setButtonEnableShadow(self._ccbOwner.btn_reward_perview)

    self._percentBarClippingNode = q.newPercentBarClippingNode(self._ccbOwner.sp_progress)
	self._totalStencilWidth = self._ccbOwner.sp_progress:getContentSize().width * self._ccbOwner.sp_progress:getScaleX()
	-- self._initTotalExpScaleX = self._ccbOwner.sp_progress:getScaleX()

    self._challengeNodes = {}
    self:updateTopPage()
    self._userInfo = nil
    self._waveFighterInfo = nil
    self._waveBoxInfo = nil
	self._isBattleAction = false
	self._isFirstShop = true
end


function QUIDialogMetalAbyssMain:updateTopPage()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if page and page.setAllUIVisible then page:setAllUIVisible(true) end
    if page and page.setManyUIVisible then page:setManyUIVisible(true) end
    if page and page.setScalingVisible then page:setScalingVisible(false) end
    if page and page.topBar and page.topBar.showWithMountReborn then
        page.topBar:showWithMountReborn()
    end

end

function QUIDialogMetalAbyssMain:viewDidAppear()
    QUIDialogMetalAbyssMain.super.viewDidAppear(self)

	self._metalAbyssProxy = cc.EventProxy.new(remote.metalAbyss)
    -- self._metalAbyssProxy:addEventListener(remote.metalAbyss.EVENT_METAl_ABYSS_UPDATE, handler(self, self._update))
	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)

    self:addBackEvent(true)
    self:setInfo()
end

function QUIDialogMetalAbyssMain:viewWillDisappear()
    QUIDialogMetalAbyssMain.super.viewWillDisappear(self)

	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)

    self._metalAbyssProxy:removeAllEventListeners()
    self:removeBackEvent()
   
end

function QUIDialogMetalAbyssMain:exitFromBattleHandler()
	--node_action_star

	local difficult = remote.metalAbyss:getAbyssLastDifficult()
	if difficult and difficult > 0 then
		self:playBattleWinAction(difficult)
	else
		-- self:playBattleWinAction(3)
		self:setInfo()
	end
end

function QUIDialogMetalAbyssMain:playBattleWinAction(difficult)
	self:setChallengeInfo()
	self._isBattleAction = true

	for i=1,3 do
		self._ccbOwner["node_cell_"..i]:setVisible(i == difficult)
	end
	self._ccbOwner.node_refresh:setVisible(false)
	local targetNode = self._challengeNodes[difficult]
	if targetNode then
		local endPos = self._ccbOwner.node_action_star:convertToWorldSpace(ccp(0, 0))
		local durMove = targetNode:playFightAction(difficult,endPos)


		local star = self._userInfo.totalStarCount or 0
		star = star - difficult
		local curLevelConfig = remote.metalAbyss:getLevelInfoByExp(star)
		local curLevelMod = remote.metalAbyss:getLevelInfoByExp(star)
		local getten = self._userInfo.todayStarCount or 0
		getten = getten - difficult
		self._ccbOwner.tf_search_getten:setString(getten)
	
		if curLevelConfig ~= nil and curLevelMod ~= nil then
			local lv = curLevelConfig.lev
			self._ccbOwner.tf_search_lv:setString("LV."..lv)
			local add = curLevelMod.reward_coefficient* 100
			self._ccbOwner.tf_search_add:setString("+"..add.."%")

		end
		local nextLevelConfig = remote.metalAbyss:getNextLevelInfoByExp(star)
		local actionArr = CCArray:create()
		actionArr:addObject(CCDelayTime:create(durMove))
		local stencil = self._percentBarClippingNode:getStencil()

		if nextLevelConfig then

			local maxExp = nextLevelConfig.star or 100
			local percent = (star - curLevelConfig.star)  / (maxExp- curLevelConfig.star)
			stencil:setPositionX(-self._totalStencilWidth + percent * self._totalStencilWidth)
			local posY = stencil:getPositionY()
			local moveX = {}
		
			star = star + difficult
			local durper = 0.3
			if star >= maxExp then --升级
				local x = 0
				actionArr:addObject(CCMoveTo:create(durper,  ccp(x, posY)))
				actionArr:addObject(CCMoveTo:create(0,  ccp(-self._totalStencilWidth, posY)))
				local nextnextLevelConfig = remote.metalAbyss:getNextLevelInfoByExp(star)

				if nextnextLevelConfig then
					local percent1 = (star - nextLevelConfig.star)  / ((nextnextLevelConfig.star or 100 ) - nextLevelConfig.star)
					x = -self._totalStencilWidth + percent1 * self._totalStencilWidth
					actionArr:addObject(CCMoveTo:create(durper,  ccp(x, posY)))
				end
			else
				local percent1 = (star - curLevelConfig.star)  / ((nextLevelConfig.star or 100 ) - curLevelConfig.star)
				local x = -self._totalStencilWidth + percent1 * self._totalStencilWidth
				actionArr:addObject(CCMoveTo:create(durper,  ccp(x, posY)))
			end
		else
			stencil:setPositionX(0)
		end
		actionArr:addObject(CCCallFunc:create(function()
			self:playLevelUpEnd()
	    end))
		stencil:runAction(CCSequence:create(actionArr))
	else
		self:playLevelUpEnd()
	end
end

function QUIDialogMetalAbyssMain:playLevelUpEnd()
	remote.metalAbyss:setAbyssLastDifficult(0)

	local rewards = remote.metalAbyss:getAbyssLevelUpReward()
	if rewards and rewards ~= "" then
  		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass= "QUIDialogMetalAbyssLevelUp",
    		options = { callBack = function ()
				if self:safeCheck() then
					self._isBattleAction = false
					remote.metalAbyss:setAbyssLevelUpReward("")
					self:setInfo()
				end
    		end}},{isPopCurrentDialog = false} )
	else
		self._isBattleAction = false
		self:setInfo()
	end
end

function QUIDialogMetalAbyssMain:resetAll()
	self._ccbOwner.node_challenge:setVisible(false)
	self._ccbOwner.node_box_prizes:setVisible(false)
	self._ccbOwner.node_final_shop:setVisible(false)
	-- self._ccbOwner.node_progress_info:setVisible(false)
	self._ccbOwner.node_refresh:setVisible(false)
	self._ccbOwner.node_enter:setVisible(false)
	self._ccbOwner.node_resetBtn:setVisible(false)
	self._ccbOwner.node_goto_next:setVisible(false)
	self._ccbOwner.node_prize:setVisible(false)

	--背景
	self._ccbOwner.sp_bg_start:setVisible(false)
	self._ccbOwner.sp_bg_end:setVisible(false)
	self._ccbOwner.sp_bg_mid:setVisible(false)
	self._ccbOwner.sp_cover:setVisible(false)
	self._ccbOwner.node_fca_fire:setVisible(false)
	self._ccbOwner.node_final_box:setVisible(false)
	self._ccbOwner.node_normal_prize:setVisible(false)

end


function QUIDialogMetalAbyssMain:setEnterInfo()
	print("==========	setEnterInfo	==========")
	self:resetAll()
	self._ccbOwner.node_enter:setVisible(true)
	self._ccbOwner.sp_bg_start:setVisible(true)

	local arr = CCArray:create()
	arr:addObject(CCScaleTo:create(0.6, 1.2, 1.2))
	arr:addObject(CCScaleTo:create(0.6,  1, 1))
    self._ccbOwner.sp_start:stopAllActions()
	self._ccbOwner.sp_start:runAction(CCRepeatForever:create(CCSequence:create(arr)))

	self:updateProgressInfo(0)
	self:updateSearchInfo()
end

function QUIDialogMetalAbyssMain:setInfo()
	self:resetAll()
	self._userInfo = remote.metalAbyss:getAbyssUserInfo()
	local curWave = self._userInfo.waveId or 0
	local daliyResetNum = 1
	self._resetNum = daliyResetNum - self._userInfo.resetCount or 0
	self:checkShopTip()

	if curWave == 0 then
		self:setEnterInfo()
	else
    	self._waveFighterInfo = remote.metalAbyss:getAbyssWaveFighterInfo()
    	self._waveBoxInfo = remote.metalAbyss:getAbyssWaveBoxInfo()
    	self._waveShopInfo = remote.metalAbyss:getAbyssWaveShopInfo()
		self:updateProgressInfo(curWave)

		-- self:showResetBtn()
		local difficult = remote.metalAbyss:getAbyssLastDifficult()
		-- local rewards = remote.metalAbyss:getAbyssLevelUpReward()
		if difficult and difficult > 0 then
			self:setChallengeInfoDefault()
			self:updateSearchInfo(difficult)
			return
		end
		self:updateSearchInfo()
		if self._waveFighterInfo and self._waveFighterInfo.status == QUIDialogMetalAbyssMain.CUR_STAGE_STATE.INIT_STATE then --显示对手
			self:setChallengeInfo()		
		elseif self._waveBoxInfo and self._waveBoxInfo.status == QUIDialogMetalAbyssMain.CUR_STAGE_STATE.INIT_STATE then --显示宝箱
			self:setBoxInfo()
		-- elseif self._waveBoxInfo and self._waveBoxInfo.status == QUIDialogMetalAbyssMain.CUR_STAGE_STATE.COMPLETE_STATE then --显示进入下一关界面
		-- 	self:setGotoNext()
		elseif self._waveFighterInfo and self._waveFighterInfo.status == QUIDialogMetalAbyssMain.CUR_STAGE_STATE.COMPLETE_STATE  
		and self._waveBoxInfo and self._waveBoxInfo.status == QUIDialogMetalAbyssMain.CUR_STAGE_STATE.COMPLETE_STATE then --显示进入下一关界面
			self:setGotoNext()
		elseif curWave == 5 then --显示最终商店
			self:setFinalShopInfo()
		else --显示进入下一关界面
			self:setGotoNext()
		end
	end
end

function QUIDialogMetalAbyssMain:checkShopTip()
	self._ccbOwner.shop_tips:setVisible(remote.metalCity:checkMetalCityShopRedTips())
end

function QUIDialogMetalAbyssMain:updateSearchInfo(diff)
	--node_mySearchInfo
	-- if true then
	-- 	return
	-- end
	local star = self._userInfo.totalStarCount or 0
	if diff then
		star = star - diff
	end
	local curLevelConfig = remote.metalAbyss:getLevelInfoByExp(star)
	local curLevelMod = remote.metalAbyss:getLevelInfoByExp(star)

	local getten = self._userInfo.todayStarCount or 0
	if diff then
		getten = getten - diff
	end	
	self._ccbOwner.tf_search_getten:setString(getten)

	if curLevelConfig == nil then
		self._ccbOwner.node_mySearchInfo:setVisible(false)
		return
	end
	self._ccbOwner.node_mySearchInfo:setVisible(true)
	local lv = curLevelConfig.lev
	self._ccbOwner.tf_search_lv:setString("LV."..lv)

	if curLevelMod then
		local add = curLevelMod.reward_coefficient* 100
		self._ccbOwner.tf_search_add:setString("+"..add.."%")
	end


	--
	local nextLevelConfig = remote.metalAbyss:getNextLevelInfoByExp(star)
	local stencil = self._percentBarClippingNode:getStencil()
	if not nextLevelConfig then
		-- 说明已经满级了，没有下一级的config。
    	stencil:setPositionX(-self._totalStencilWidth + 1*self._totalStencilWidth)
    	self._ccbOwner.tf_search_lv:setString("MAX")
		return
	end

	local maxExp = nextLevelConfig.star or 100
	local percent = (star - curLevelConfig.star)  / (maxExp - curLevelConfig.star)
	stencil:setPositionX(-self._totalStencilWidth + percent*self._totalStencilWidth)


end


function QUIDialogMetalAbyssMain:updateProgressInfo(curStage)
	self._ccbOwner.sp_progress_mark:setVisible(false)
	for i=1,5 do
		local spNode = self._ccbOwner["sp_progress_"..i]
		spNode:setScale(0.75)
		if i > curStage then
			makeNodeFromNormalToGray(spNode)
		elseif i == curStage then 
			spNode:setScale(1)
			makeNodeFromGrayToNormal(spNode)
			self._ccbOwner.sp_progress_mark:setPositionY(spNode:getPositionY())
			self._ccbOwner.sp_progress_mark:setVisible(true)
		else
			makeNodeFromGrayToNormal(spNode)
		end
	end

end

function QUIDialogMetalAbyssMain:setChallengeInfo()
	print("==========	setChallengeInfo	==========")
	self._ccbOwner.node_refresh:setVisible(true)
	self._ccbOwner.sp_bg_mid:setVisible(true)
	self._ccbOwner.node_challenge:setVisible(true)
	self._ccbOwner.sp_cover:setVisible(true)
	for i=1,3 do
		self._ccbOwner["node_cell_"..i]:setVisible(true)
		local node = self._challengeNodes[i]
		if node == nil then
			node =  QUIWidgetMetalAbyssFighterInfo.new()
			node:addEventListener(QUIWidgetMetalAbyssFighterInfo.EVENT_BATTLE, handler(self, self.startBattleHandler))
			node:addEventListener(QUIWidgetMetalAbyssFighterInfo.EVENT_VISIT, handler(self, self.clickCellHandler))
			node:setScale(0.95)
			self._ccbOwner["node_cell_"..i]:addChild(node)
			table.insert(self._challengeNodes , node)
		end
		node:setInfo(self._waveFighterInfo.fighters[i] , i , true)
	end
	local freeRefreshNum = db:getConfiguration()["abyss_day_refresh_count"].value 
	local refreshNum = freeRefreshNum - self._userInfo.refreshCount
	self._ccbOwner.tf_refresh_times:setString(refreshNum)
	-- if refreshNum <= 0 then

	-- end
end


function QUIDialogMetalAbyssMain:setChallengeInfoDefault()
	print("==========	setChallengeInfoDefault	==========")
	self._ccbOwner.node_refresh:setVisible(false)
	self._ccbOwner.sp_bg_mid:setVisible(true)
	self._ccbOwner.node_challenge:setVisible(true)
	self._ccbOwner.sp_cover:setVisible(true)
	for i=1,3 do
		self._ccbOwner["node_cell_"..i]:setVisible(false)
	end
end


function QUIDialogMetalAbyssMain:setGotoNext()
	print("==========	setGotoNext	==========")
	self._ccbOwner.sp_bg_mid:setVisible(true)
	self._ccbOwner.node_goto_next:setVisible(true)
	self._ccbOwner.node_fca_fire:setVisible(true)
	self._ccbOwner.sp_goNext:setScale(0.8)
	local arr = CCArray:create()
	arr:addObject(CCScaleTo:create(0.6, 1, 1))
	arr:addObject(CCScaleTo:create(0.6,  0.8, 0.8))
    self._ccbOwner.sp_goNext:stopAllActions()
	self._ccbOwner.sp_goNext:runAction(CCRepeatForever:create(CCSequence:create(arr)))
	
end

function QUIDialogMetalAbyssMain:setBoxInfo()
	print("==========	setBoxInfo	==========")
	self._ccbOwner.sp_bg_mid:setVisible(true)
	self._ccbOwner.node_box_prizes:setVisible(true)	
	self._ccbOwner.sp_cover:setVisible(true)
	self._ccbOwner.node_normal_prize:setVisible(true)
	self._boxIsGold = self._waveBoxInfo.boxType == 1 

	if self._boxIsGold then
		self:getActionNode(self._ccbOwner.node_normal_prize,8,true)
	else
		self:getActionNode(self._ccbOwner.node_normal_prize,6,true)
	end

end

function QUIDialogMetalAbyssMain:setFinalShopInfo()
	print("==========	setFinalShopInfo	==========")
	self._ccbOwner.sp_bg_end:setVisible(true)
	self._ccbOwner.node_final_shop:setVisible(true)
	self._ccbOwner.node_final_box:setVisible(true)

	self._ccbOwner.node_final_box:removeAllChildren()
	self:getActionNode(self._ccbOwner.node_final_box,3,true)

end

function QUIDialogMetalAbyssMain:setVisibleWithoutBgAndAction(isVisible)
	print("==========	setVisibleWithoutBgAndAction	==========")
	self._ccbOwner.node_ui:setVisible(isVisible)
	self._ccbOwner.node_confirmBtn:setVisible(isVisible)
	self._ccbOwner.node_left:setVisible(isVisible)
	self._ccbOwner.node_bottom:setVisible(isVisible)
	self._ccbOwner.node_right:setVisible(isVisible)
	self._ccbOwner.node_info:setVisible(isVisible)
	-- self._ccbOwner.node_resetBtn:setVisible(isVisible)

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setBackHomeBtnVisible(isVisible)
    if page and page.topBar then
        page.topBar:setVisible(isVisible)
    end
end

--0.3 0.5
--0.3 0.2
function QUIDialogMetalAbyssMain:playPassWaveAction()

	local moveOffside = 800

	self:setVisibleWithoutBgAndAction(false)
	self._ccbOwner.node_action:setVisible(true)
	self._ccbOwner.node_particle:setVisible(true)
    self._ccbOwner.node_action:setPositionY(0)


    self:getActionNode(self._ccbOwner.node_particle,1,false)
    self:getActionNode(self._ccbOwner.node_action,2,false)

	local moveDurstart = q.flashFrameTransferDur(5)
	local moveDurend = q.flashFrameTransferDur(10)
	local actionDelay = q.flashFrameTransferDur(30)

	local bgArr = CCArray:create()
    bgArr:addObject(CCMoveTo:create(moveDurstart,ccp(0, moveOffside)))
    bgArr:addObject(CCCallFunc:create(function()
    	self._ccbOwner.node_bg_main:setPositionY(-moveOffside)
		if self:safeCheck() then
			self:resetAll()
			self:setChallengeInfoDefault()
		end
    end))
    bgArr:addObject(CCDelayTime:create(actionDelay))
    bgArr:addObject(CCMoveTo:create(moveDurend,ccp( 0,  0)))
    bgArr:addObject(CCCallFunc:create(function()
		self:setInfo()
    	self:setVisibleWithoutBgAndAction(true)
		self._ccbOwner.node_action:setVisible(false)
		self._ccbOwner.node_particle:setVisible(false)
    end))
    self._ccbOwner.node_bg_main:stopAllActions()
    self._ccbOwner.node_bg_main:runAction(CCSequence:create(bgArr))

	-- local actionArr = CCArray:create()
 --    actionArr:addObject(CCMoveTo:create(moveDur,ccp( 0,  0)))
 --    actionArr:addObject(CCDelayTime:create(actionDelay))
 --    actionArr:addObject(CCCallFunc:create(function()
	-- 	if self:safeCheck() then
	-- 		self:setInfo()
	-- 	end
 --    end))
 --    actionArr:addObject(CCMoveTo:create(moveDur,ccp( 0, moveOffside - 50)))
 --    actionArr:addObject(CCDelayTime:create(0.1))
 --    actionArr:addObject(CCCallFunc:create(function()
	-- 	self._ccbOwner.node_action:removeAllChildren()
	-- 	self._ccbOwner.node_particle:removeAllChildren()
 --    end))

 --    self._ccbOwner.node_action:stopAllActions()
 --    self._ccbOwner.node_action:runAction(CCSequence:create(actionArr))

end

function QUIDialogMetalAbyssMain:_checkNeedRefresh(e)
	local needRefresh = remote.metalAbyss:getAbyssRefreshMark()

	if needRefresh then
		-- app.tip:floatTip("金属深渊玩法自动刷新")
		remote.metalAbyss:abyssGetMainInfoRequestRequest(function(data)
			if self:safeCheck() then
				self:setInfo()
			end
		end)
		return true
	end
	return false
end


function QUIDialogMetalAbyssMain:getActionNode(node,aniType , loop)
	node:removeAllChildren()
	local resAni = QResPath("metalAbyss_ani")[aniType]
    local fcaAnimation = QUIWidgetFcaAnimation.new(resAni, "res")
    node:addChild(fcaAnimation)
    fcaAnimation:playAnimation("animation", loop)
	return fcaAnimation
end


function QUIDialogMetalAbyssMain:showResetBtn()
	self._ccbOwner.node_resetBtn:setVisible(true)
	if self._resetNum > 0  then
		makeNodeFromGrayToNormal(self._ccbOwner.node_resetBtn)
	else
		makeNodeFromNormalToGray(self._ccbOwner.node_resetBtn)
	end
end


function QUIDialogMetalAbyssMain:_onPressNormalPrize(e)
	if self._isBattleAction then return end
	if self:_checkNeedRefresh() then return end

    app.sound:playSound("common_small")

	if self._waveBoxInfo and self._waveBoxInfo.status == QUIDialogMetalAbyssMain.CUR_STAGE_STATE.INIT_STATE then
		self._isBattleAction = true
	    app.sound:playSound("common_small")
	    local fcaIdx = 7
		if self._boxIsGold then
			fcaIdx = 9
		end

		local fcaAnimation = self:getActionNode(self._ccbOwner.node_normal_prize,fcaIdx,false)
  		fcaAnimation:setEndCallback(function( )
                fcaAnimation:removeFromParent()
                if self:safeCheck() then
					RunActionDelayTime(self:getView(), function()
                  		self._isBattleAction = false
						self:_onRequestOpenWaveBox()
					end, 0.1)	
                end
            end)
	else
		self:setInfo()
	end

end

function QUIDialogMetalAbyssMain:_onRequestOpenWaveBox()
	if self._isBattleAction then return end
	if self:_checkNeedRefresh() then return end
	remote.metalAbyss:abyssOpenWaveBoxRequest(self._userInfo.waveId,function(data)
		local awards =  data.prizes or {}
		if data.wallet then
			remote.user:update(data.wallet)
		end
		if data.items then 
			remote.items:setItems(data.items) 
		end
  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
    		options = {awards = awards, callBack = function ()
				if self:safeCheck() then
					self:setInfo()
				end
    		end}},{isPopCurrentDialog = false} )
		dialog:setTitle("恭喜获得金属深渊奖励")
	end)
end



function QUIDialogMetalAbyssMain:_onPressFinalPirze(e)
	print("QUIDialogMetalAbyssMain:_onPressFinalPirze")
	if self._isBattleAction then return end
	if self:_checkNeedRefresh() then return end

	if self._waveShopInfo then
		self._isBattleAction = true
	    app.sound:playSound("common_small")
		local fcaAnimation = self:getActionNode(self._ccbOwner.node_final_box,4,false)
		if self._isFirstShop then
			self._isFirstShop = false
		else
			fcaAnimation:setAnimationScale(3)
		end
  		fcaAnimation:setEndCallback(function( )
                  self._isBattleAction = false
                if self:safeCheck() then
                	self:setFinalShopInfo()
                   	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMetalAbyssFinalShop",
						options = {userInfo = self._userInfo}}, {isPopCurrentDialog = false})
                end
            end)	

	end

	
end

function QUIDialogMetalAbyssMain:_onTriggerRule(e)
	if self._isBattleAction then return end
    app.sound:playSound("common_small")
  	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMetalAbyssHelp",
    	options = {}}, {isPopCurrentDialog = false})	
end

function QUIDialogMetalAbyssMain:_onTriggerRank(e)


	if self._isBattleAction then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRank", 
        options = {initRank = "metalAbyss"}}, {isPopCurrentDialog = false})

end

function QUIDialogMetalAbyssMain:_onTriggerRefresh(e)
	if self._isBattleAction then return end
	if self:_checkNeedRefresh() then return end
    app.sound:playSound("common_small")

	local changeCount = self._userInfo.refreshCount or 0
	local freeRefreshNum = db:getConfiguration()["abyss_day_refresh_count"].value 
	local refreshNum = freeRefreshNum - changeCount
	if refreshNum <= 0 then
		app.tip:floatTip("您今天更换对手的次数已经用完！")
		return 
	end

	local consumeConfig, isExist = db:getTokenConsume("abyss_times", changeCount+1)
	-- if not isExist then
	-- 	app.tip:floatTip("您今天更换对手的次数已经用完！")
	-- 	return 
	-- end

	-- 钻石不足
	if (consumeConfig.money_num or 0) > remote.user.token then
		QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
		return
	end
	local content = string.format("##n确认##e花费%d钻石##n更换对手？",  consumeConfig.money_num)
	app:alert({content = content, callback = function(state)
	        if state == ALERT_TYPE.CONFIRM then
				remote.metalAbyss:abyssRefreshRequest(self._userInfo.waveId,function(data)
					if data.wallet then
						remote.user:update(data.wallet)
					end
					if data.items then 
						remote.items:setItems(data.items) 
					end

					if self:safeCheck() then
						self:setInfo()
					end
				end)
	        end
	    end, colorful = true})
end

--显示当前星级与下一级星级奖励
function QUIDialogMetalAbyssMain:_onTriggerRewardTips(e)
	if self._isBattleAction then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMetalAbyssLevelTips"
    	, options = {x = x, y = y ,userInfo = self._userInfo}})
end

--搜索宝箱奖励
function QUIDialogMetalAbyssMain:_onTriggerTouch(e)
	-- if self._isBattleAction then return end
 --    app.sound:playSound("common_small")

	-- local exp = self._userInfo.totalStarCount or 0
	-- local nextLevelConfig = remote.metalAbyss:getNextLevelConfigByExp(exp)

	-- if nextLevelConfig == nil then
	-- 	app.tip:floatTip("搜索等级奖励已全部领取")
	-- 	return
	-- end

	-- local curLv = nextLevelConfig.lev - 1
	-- local rewardIds = {}
	-- for i=1,curLv do
	-- 	if not remote.metalAbyss:checkStarRewardsIsGetten(i) then 
	-- 		table.insert(rewardIds , i)
	-- 	end
	-- end

	-- if q.isEmpty(rewardIds) then
	-- 	--预览下一级的奖励
	-- 	local awards = db:getLuckyDrawAwardTable(nextLevelConfig.reward)
	-- 	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBoxReward",
	--         options = {
	--         	title = "宝箱奖励",
	--         	richTextConfig = {
	--         		{oType = "font", content = "领取奖励：历史累计获得星星达到",size = 22,color = GAME_COLOR_LIGHT.normal},
	--         		{oType = "font", content = nextLevelConfig.star,size = 22,color = GAME_COLOR_LIGHT.stress},
	--         		{oType = "font", content = "可领取",size = 22,color = GAME_COLOR_LIGHT.normal},
	--         	},
	--         	awards = awards
	--         	-- awards = {{id = 701, count = 10},{id = 701, count = 10}}
	--         }},{isPopCurrentDialog = false})

	-- else
	-- 	remote.metalAbyss:abyssGetStarRewardRequest(rewardIds,function(data)
	-- 		local awards = data.prizes or {}
	--   		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
	--     		options = {awards = awards, callBack = function ()
	-- 				if self:safeCheck() then
	-- 					self:setInfo()
	-- 				end
	--     		end}},{isPopCurrentDialog = false} )
	--     	dialog:setTitle("恭喜获得金属深渊奖励")


	-- 	end)		
	-- end
end

function QUIDialogMetalAbyssMain:_onTriggerReset(e)
	-- if self._isBattleAction then return end
 --    app.sound:playSound("common_small")
	-- if self._resetNum <= 0 then
	-- 	app.tip:floatTip(QUIDialogMetalAbyssMain.RESET_TIPS)
	-- 	return
	-- end

	-- app:alert({content = "##n确认是否需要重置当前探索？", callback = function(state)
	--         if state == ALERT_TYPE.CONFIRM then
	-- 			remote.metalAbyss:abyssResetRequest(function(data)
	-- 				if self:safeCheck() then
	-- 					self:setInfo()
	-- 				end
	-- 			end)
	--         end
	--     end, colorful = true})

end

function QUIDialogMetalAbyssMain:_onPressGotoNext(e)
	if self._isBattleAction then return end
	if self:_checkNeedRefresh() then return end
    app.sound:playSound("common_small")
  	local isFighter = self._waveFighterInfo and self._waveFighterInfo.status == QUIDialogMetalAbyssMain.CUR_STAGE_STATE.COMPLETE_STATE
	remote.metalAbyss:abyssPassWaveRequest( self._userInfo.waveId, isFighter , function(data)
		if self:safeCheck() then
			self:playPassWaveAction()
		end
	end)
end

function QUIDialogMetalAbyssMain:_onTriggerStartSearch(e)
	if self._isBattleAction then return end

    app.sound:playSound("common_small")
	remote.metalAbyss:abyssPassWaveRequest( self._userInfo.waveId, false,function(data)
		if self:safeCheck() then
			self:playPassWaveAction()
		end
	end)

end

function QUIDialogMetalAbyssMain:_onTriggerStore(e)
	-- self:playBattleWinAction(3)
	app.sound:playSound("common_small")
	remote.stores:openShopDialog(SHOP_ID.metalCityShop)
end

function QUIDialogMetalAbyssMain:_onTriggerRewardPerview(e)
	app.sound:playSound("common_small")
    -- app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMetalAbyssRewardPerview", 
    --     options = {}}, {isPopCurrentDialog = false})
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMetalAbyssRewardPerviewTips", 
        options = {}})

    
end

function QUIDialogMetalAbyssMain:clickCellHandler(event)
	
	if self._isBattleAction then return end
	if self:_checkNeedRefresh() then return end

    app.sound:playSound("common_small")

	remote.metalAbyss:abyssQueryFighterRequest(event.info.userId, function(data)
		local fighter = (data.towerFightersDetail or {})[1]
  		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfoThreeTeam",
                options = {fighter = fighter, isPVP = true}}, {isPopCurrentDialog = false})
	end)

end

function QUIDialogMetalAbyssMain:startBattleHandler(event)
	if self._isBattleAction then return end
	if self:_checkNeedRefresh() then return end

    app.sound:playSound("common_small")

	remote.metalAbyss:abyssQueryFighterRequest(event.info.userId, function(data)
		local fighter =(data.towerFightersDetail or {})[1]
		local teamIndexIds = {
			remote.teamManager.TEAM_INDEX_MAIN ,
			remote.teamManager.TEAM_INDEX_HELP ,
			remote.teamManager.TEAM_INDEX_GODARM ,
		}
		local teamKeys ={
			remote.teamManager.METAL_ABYSS_TEAM1,
			remote.teamManager.METAL_ABYSS_TEAM2,
			remote.teamManager.METAL_ABYSS_TEAM3,
		}
		local arrangement = QMetalAbyssArrangement.new(
			{teamKey = remote.teamManager.METAL_ABYSS_TEAM1 
			, teamKeys = teamKeys
			, teamIndexIds = teamIndexIds
			, enemyFighter = fighter
			})

		local buttonTypes = {1,2,3,4}

		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass= "QUIDialogTeamArrangementNew",
			options = {arrangement = arrangement , isFighter = true ,buttonTypes= buttonTypes, fighterStr = "敌方队伍" , isBattle = true}})
	end)

end

return QUIDialogMetalAbyssMain	
