local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSparField = class("QUIDialogSparField", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetSparFieldSmallChest = import("..widgets.sparField.QUIWidgetSparFieldSmallChest")
local QUIWidgetSparFieldFighter = import("..widgets.sparField.QUIWidgetSparFieldFighter")
local QSparFieldArrangement = import("...arrangement.QSparFieldArrangement")
local QUIWidgetTalkController = import("..widgets.QUIWidgetTalkController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetActorDisplay = import("...ui.widgets.actorDisplay.QUIWidgetActorDisplay")
local QQuickWay = import("...utils.QQuickWay")
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSunWarFireEffect = import("..widgets.QUIWidgetSunWarFireEffect")

function QUIDialogSparField:ctor(options)
	local ccbFile = "ccb/Dialog_sparfield.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerRule", callback = handler(self, self._onTriggerRule)},     
        {ccbCallbackName = "onTriggerRefresh", callback = handler(self, self._onTriggerRefresh)},   
        {ccbCallbackName = "onTriggerShop", callback = handler(self, self._onTriggerShop)},   
        {ccbCallbackName = "onTriggerRank", callback = handler(self, self._onTriggerRank)},   
        {ccbCallbackName = "onTriggerHeroTips", callback = handler(self, self._onTriggerHeroTips)},   

	}
	QUIDialogSparField.super.ctor(self,ccbFile,callBacks,options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setManyUIVisible()
    page:setScalingVisible(false)
    page.topBar:showWithStyle({TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.JEWELRY_MONEY, TOP_BAR_TYPE.BATTLE_FORCE_FOR_SPAR})

    local words = QStaticDatabase:sharedDatabase():getDialogue(3)
    self._sparTalkController = QUIWidgetTalkController.new({words = words})

	self:stopArrowAnimation()
	self._ccbOwner.node_empty:setVisible(false)
	self._schedulerHandlers = {}

	self._topNForce = remote.herosUtil:getMostHeroBattleForce(true)

	self._fireEffect = QUIWidgetSunWarFireEffect.new()
	self:getView():addChild(self._fireEffect)
	self._mapPath = remote.sparField:getSparMap()
	self._ccbOwner.sp_map:setTexture(CCTextureCache:sharedTextureCache():addImage(self._mapPath))
end

function QUIDialogSparField:viewDidAppear()
    QUIDialogSparField.super.viewDidAppear(self)
  	self:addBackEvent(false)

  	self:sparFieldStep(true)

	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)
end

function QUIDialogSparField:viewWillDisappear()
    QUIDialogSparField.super.viewWillDisappear(self)
	self:removeBackEvent()
	if self._schedulerHandlers ~= nil then
		for _,handler in ipairs(self._schedulerHandlers) do
			scheduler.unscheduleGlobal(handler)
		end
		self._schedulerHandlers = {}
	end
	self._sparTalkController:removeAllAvatarTalk()
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)
	remote.sparField:removeSparFieldLegendHeros()
	if self._fireEffect ~= nil then
		self._fireEffect:removeFromParent()
	end
end

function QUIDialogSparField:onTriggerBackHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogSparField:onTriggerHomeHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

--设置晶石场的步骤
function QUIDialogSparField:sparFieldStep(isFrist)
	local status,waveId,isFighter = remote.sparField:getStatus()
	self._waveId = waveId
	self._isFighter = isFighter
	self:showMyInfo(false)
	self:setStep(waveId,status)
	local result = true
  	if status == remote.sparField.STATUS_BOX then
		result = self:playSmallChestInAnimation(isFrist == false)
	elseif status == remote.sparField.STATUS_FIGHT then
		result = self:playFightInAnimation(isFrist == false)
	elseif status == remote.sparField.STATUS_GO or result == false then
		if remote.sparField:getInBattle() == true then
			self:stopArrowAnimation()
			self:playFightInAnimation(false)
			self:playMoveAnimation(nil, false)

			--为了实现星星的一个的动画
			local starOffset = remote.sparField:getFightStarCount()
			local myInfo = remote.sparField:getSparFieldMyInfo()
			local todayStarCount = myInfo.startCount or 0
			self._ccbOwner.tf_star_count:setString(todayStarCount - starOffset)
		else
			self:playArrowAnimation()
		end
	elseif status == remote.sparField.STATUS_END then
		if self._waveId == remote.sparField.FINAL_WAVE then
			local myInfo = remote.sparField:getSparFieldMyInfo()
			if myInfo.getFinalReward ~= true then
				self:getFinalReward()
			else
				self:showFinal()
			end
		end
	end
end

--显示个人的晶石场信息
function QUIDialogSparField:showMyInfo(isAnimation)
	local myInfo = remote.sparField:getSparFieldMyInfo()
	local starCount = myInfo.totalStarCount or 0
	local todayStarCount = myInfo.startCount or 0
	local starConfig = QStaticDatabase:sharedDatabase():getSparFieldLevelByStarCount(starCount)
	if starConfig == nil then 
		starConfig = {}
	end
	self._sparLevel = starConfig.lev or 0
	local starNextConfig = QStaticDatabase:sharedDatabase():getSparFieldLevelById((starConfig.lev or 0)+1)
	if starNextConfig == nil then
		self._ccbOwner.tf_progress:setString("已到顶级")
		self._ccbOwner.sp_progress:setScaleX(2)
	else
		self._ccbOwner.tf_progress:setString(starCount.."/"..starNextConfig.star)
		self._ccbOwner.sp_progress:setScaleX((starCount/starNextConfig.star) * 2)
	end
	self._ccbOwner.tf_level:setString("LV."..(starConfig.lev or 0))
	self._ccbOwner.tf_star_count:setString(todayStarCount)

	local refreshCount = myInfo.legendHeroRefreshCount or 1
	local tokenConsume = QStaticDatabase:sharedDatabase():getTokenConsume("spar_legend_hero_refresh", refreshCount)
	self._ccbOwner.tf_token:setString(tokenConsume.money_num)

	--设置传奇魂师
	self._ccbOwner.node_hero:removeAllChildren() 
	for index,actorId in ipairs(myInfo.legendHeroIds or {}) do
		local characterConfig = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
		local sacle = 0.5
		local sp = CCNode:create()
		local head = CCSprite:create(characterConfig.icon)
		head:setScale(sacle)
		sp:addChild(head)
		local kuang = CCSprite:create(QResPath("spar_hero_kuang"))
		kuang:setScale(1.2 * sacle)
		sp:addChild(kuang)
		local posX = (index - 1) * 60
		sp:setPositionX(posX)
		self._ccbOwner.node_hero:addChild(sp,999-index)
		if remote.herosUtil:checkIdInTopN(actorId) then
			local signSp = CCSprite:create(QResPath("spar_hero_yongyou"))
			signSp:setPositionY(18)
			signSp:setPositionX(17)
			sp:addChild(signSp)
		end

		if isAnimation then
			sp:setScale(1.2)
			local arr = CCArray:create()
			arr:addObject(CCScaleTo:create(0.15, 0.9, 0.9))
			arr:addObject(CCScaleTo:create(0.12, 1.1, 1.1))
			arr:addObject(CCScaleTo:create(0.1, 1, 1))
			sp:runAction(CCSequence:create(arr))
		end
	end
	remote.sparField:removeSparFieldLegendHeros()
	local heroInfos, count = remote.herosUtil:getMaxForceHeros(true)
	remote.sparField:addSparFieldLegendHeros()
	local topNForce = 0
	for index,heroInfo in ipairs(heroInfos) do
		if index > count then
			break
		end
		local heroProp = remote.herosUtil:createHeroPropById(heroInfo.id)
		topNForce = topNForce + heroProp:getBattleForce(true)
	end
	local addForce = (topNForce - self._topNForce)/self._topNForce*100
	self._ccbOwner.tf_buff:setString(string.format("今日战神（战力提升%d%%）：", addForce))

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	local topBar = page.topBar:getBarForType(TOP_BAR_TYPE.BATTLE_FORCE_FOR_SPAR)
	topBar:showSunWarBattleBuff(math.floor(addForce))

	if isAnimation and self._currentTopNForce ~= nil and topNForce > self._currentTopNForce then
		self:enableTouchSwallowTop()
		local offsetForce = topNForce - self._currentTopNForce
		local topBarPos = topBar:convertToWorldSpace(ccp(0,0))
		topBarPos = self:getView():convertToNodeSpace(topBarPos)
	    local currentPos = self._ccbOwner.node_hero:convertToWorldSpace(ccp(0,0))
		currentPos = self:getView():convertToNodeSpace(currentPos)
		self._fireEffect:showBuffEffect(currentPos.x + 130, currentPos.y, topBarPos.x-90, topBarPos.y,function ()
			topBar:showTipsAnimation(offsetForce)
			self:disableTouchSwallowTop()
		end)
	elseif self._currentTopNForce ~= nil and topNForce ~= self._currentTopNForce then
		topBar:showTipsAnimation(topNForce - self._currentTopNForce)
	end
	self._currentTopNForce = topNForce


	--设置奖励
	local reward = starConfig.reward
	if reward == nil or reward == 0 then
		reward = starNextConfig.reward
	end
	local awards = QStaticDatabase:sharedDatabase():getluckyDrawById(reward)
	self:setStarAwards(awards)

	--商店小红点
	self._ccbOwner.sp_shop_tips:setVisible(remote.exchangeShop:checkExchangeShopRedTipsById(SHOP_ID.sparShop))
end

--播放箭头指向动画
function QUIDialogSparField:playArrowAnimation()
	self._ccbOwner.sp_arrow:setVisible(true)
	local arr = CCArray:create()
	arr:addObject(CCScaleTo:create(0.2, 1.1, 1.1))
	arr:addObject(CCScaleTo:create(0.2, 1, 1))
	arr:addObject(CCScaleTo:create(0.2, 1.1, 1.1))
	arr:addObject(CCScaleTo:create(0.2, 1, 1))
	arr:addObject(CCDelayTime:create(1))
	self._arrowActionHandler = self._ccbOwner.sp_arrow:runAction(CCRepeatForever:create(CCSequence:create(arr)))
end

--停止箭头指向动画
function QUIDialogSparField:stopArrowAnimation()
	if self._arrowActionHandler ~= nil then
		self._ccbOwner.sp_arrow:stopAction(self._arrowActionHandler)
		self._arrowActionHandler = nil
	end
	self._ccbOwner.sp_arrow:setVisible(false)
end

--播放前进动画
function QUIDialogSparField:playMoveAnimation(callback, isAnimation)
	local animationName = "move"
	if isAnimation == false then
		animationName = "end"
	end
	self:enableTouchSwallowTop()
	if self._bg == nil then
		self._bg = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.map_content:addChild(self._bg)
	end
	if isAnimation ~= false then
    	app.sound:playSound("spar_walk")
    end
	self._bgCCB = self._bg:playAnimation("ccb/effects/jingshiyudi_qianjin_1.ccbi", nil, function ()
		self:disableTouchSwallowTop()
		if callback then
			callback()
		end
	end, false, animationName)
	self._bgCCB.sp_map:setTexture(CCTextureCache:sharedTextureCache():addImage(self._mapPath))
end

--播放对手入场动画
function QUIDialogSparField:playFightInAnimation(isAnimation)
	local sparFieldInfo = remote.sparField:getSparFieldFightInfo()
	if sparFieldInfo == nil or sparFieldInfo.fighterInfo == nil then
		return false
	end
	local fightInfos = sparFieldInfo.fighterInfo.fighters or {}
	self:removeAllFighters()
	if self._schedulerHandlers ~= nil then
		for _,handler in ipairs(self._schedulerHandlers) do
			scheduler.unscheduleGlobal(handler)
		end
		self._schedulerHandlers = {}
	end
	local callback = function ()
		for index,fightInfo in ipairs(fightInfos) do
			local fighter = QUIWidgetSparFieldFighter.new()
			table.insert(self.fighters, fighter)
			self._sparTalkController:addAvatarTalk(fighter)
			self._ccbOwner["node_avatar"..index]:addChild(fighter)
			fighter:addEventListener(QUIWidgetSparFieldFighter.EVENT_CLICK, handler(self, self.fightClickHandler))
			if isAnimation then
				fighter:setVisible(false)
				local handler = scheduler.performWithDelayGlobal(function ()
					fighter:setFightInfo(fightInfo, isAnimation, index)
					fighter:setVisible(true)
				end, (index) * 0.2)
				table.insert(self._schedulerHandlers, handler)
			else
				fighter:setFightInfo(fightInfo, isAnimation, index)
			end
		end
		local handler = scheduler.performWithDelayGlobal(function ()
			self._sparTalkController:avatarTalkTime()
		end, (#fightInfos) * 0.2 + 0.5)
		table.insert(self._schedulerHandlers, handler)
	end
	if isAnimation then
		local effectPlayer = QUIWidgetAnimationPlayer.new()
		effectPlayer:setPositionY(-100)
		self:getView():addChild(effectPlayer)
		effectPlayer:playAnimation("ccb/effects/widget_spar_boss.ccbi",function (ccbOwner)
			local resPaths = QResPath("spar_fighter_tip")
			local resPath = resPaths[self._waveId]
			if resPath ~= nil then
				local texture = CCTextureCache:sharedTextureCache():addImage(resPath)
				local size = texture:getContentSize()
				local rect = CCRectMake(0, 0, size.width, size.height)
				if self._waveId == remote.sparField.FINAL_WAVE then
					ccbOwner.sp_normal:setVisible(false)
					ccbOwner.sp_red:setVisible(false)
					ccbOwner.sp_back_normal:setTexture(texture)
					ccbOwner.sp_back_normal:setTextureRect(rect)
					ccbOwner.sp_back_red:setTexture(texture)
					ccbOwner.sp_back_red:setTextureRect(rect)
				else
					ccbOwner.sp_normal:setTexture(texture)
					ccbOwner.sp_normal:setTextureRect(rect)
					ccbOwner.sp_red:setTexture(texture)
					ccbOwner.sp_red:setTextureRect(rect)
				end
			end
		end, callback)
	else
		callback()
	end
	return true
end

--播放对手出场动画
function QUIDialogSparField:playFightOutAnimation()
	for _,fighter in ipairs(self.fighters) do
		fighter:playDisappearEffect()
	end
	self._sparTalkController:removeAllAvatarTalk()
end

--删除界面上的所有对手
function QUIDialogSparField:removeAllFighters()
	if self.fighters ~= nil then
		for _,fighter in ipairs(self.fighters) do
			fighter:removeFromParent()
		end
	end
	self.fighters = {}
end

--播放小宝箱掉落的动画
function QUIDialogSparField:playSmallChestInAnimation(isAnimation)
	self:_removeAllChest()
	local sparFieldInfo = remote.sparField:getSparFieldFightInfo()
	if sparFieldInfo == nil or sparFieldInfo.boxInfo == nil then
		return false
	end
	local chestCount = sparFieldInfo.boxInfo.boxNum or 0
	local cellW = display.width/(chestCount+1)
	for i=1,chestCount do
		local chest = QUIWidgetSparFieldSmallChest.new()
		table.insert(self._smallChests, chest)
		self._ccbOwner.node_chest:addChild(chest)
		chest:playAnimationByName("chuxian")
		chest:addEventListener(QUIWidgetSparFieldSmallChest.EVENT_CLICK, handler(self, self._clickChestHandler))
		local posX = cellW*i*math.random(90, 110)/100-display.width/2
		chest:setPositionX(posX)
		local posY = 0
		if i%2 == 1 then
			posY = math.random(-50,0)
		else
			posY = math.random(0,50)
		end
		chest:setPositionY(posY)
	end
	return true
end

function QUIDialogSparField:_clickChestHandler()
	self:enableTouchSwallowTop()
	local lastChest = nil
	for _,chest in ipairs(self._smallChests) do
		chest:playAnimationByName("kaiqi")
		lastChest = chest
	end
	lastChest:addEventListener(QUIWidgetSparFieldSmallChest.EVENT_PLAY_END, handler(self, self._openChestHandler))
	lastChest:addEventListener(QUIWidgetSparFieldSmallChest.EVENT_DISAPPEAR, handler(self, self._disappearChestHandler))
end

function QUIDialogSparField:_openChestHandler()
	remote.sparField:sparFieldOpenWaveBoxRequest(self._waveId, function (data)
		remote.sparField:setBoxStatus(1)
		local awardStr = data.sparFieldOpenWaveBoxResponse.boxReward
		local awards = {}
		awardStr = string.split(awardStr, ";")
		for _,str in ipairs(awardStr) do
			if str ~= "" then
				local v = string.split(str, "^")
				local count = tonumber(v[2])
				local typeName = remote.items:getItemType(v[1])
				local id = nil
				if typeName == nil then
					typeName = ITEM_TYPE.ITEM
					id = tonumber(v[1])
				end
				table.insert(awards, {id = id, typeName = typeName, count = count or 0})
			end
		end
		-- app.tip:awardsTip(awards,"恭喜您获得奖励", function ()
  --        	self:playBackAnimation(function ()
		-- 		self:sparFieldStep(false)
		-- 	end)
  --       end)
  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
    		options = {awards = awards, callBack = function ()
         		self:playBackAnimation(function ()
					self:sparFieldStep(false)
				end)
    		end}},{isPopCurrentDialog = false})
   		dialog:setTitle("恭喜您获得宝箱奖励")		
	end)
end

function QUIDialogSparField:_disappearChestHandler()
	self:disableTouchSwallowTop()
	self:_removeAllChest()
end

function QUIDialogSparField:_removeAllChest()
	if self._smallChests ~= nil and #self._smallChests > 0 then
		for _,chest in ipairs(self._smallChests) do
			chest:removeAllEventListeners()
			chest:removeFromParent()
		end
		self._smallChests = {}
	else
		self._smallChests = {}
	end
end

--如果有老背景的话，先播放消失动画
function QUIDialogSparField:playBackAnimation(callback)
	self:enableTouchSwallowTop()
	local fun = function ()
		self:disableTouchSwallowTop()
		if callback ~= nil then
			callback()
		end
	end
	if self._bgCCB ~= nil then
		local bgCCB = self._bgCCB
		local oldArr = CCArray:create()
		oldArr:addObject(CCFadeOut:create(0.15))
		oldArr:addObject(CCCallFunc:create(function ()
			fun()
		end))
		bgCCB.sp_map:runAction(CCSequence:create(oldArr))
	else
		fun()
	end
end

--设置界面奖励
function QUIDialogSparField:setStarAwards(awards)
	self._ccbOwner.node_awards:removeAllChildren()
	if awards == nil then return end
	local starConfig = QStaticDatabase:sharedDatabase():getSparFieldLevelById(self._sparLevel)
	if starConfig == nil then starConfig = {} end
	local posX = 0
	for _,award in ipairs(awards) do
		local path = nil
		if award.typeName == ITEM_TYPE.ITEM then
			local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(award.id)
			path = itemConfig.icon_1 or itemConfig.icon
		else
			local config = remote.items:getWalletByType(award.typeName)
			path = config.alphaIcon or config.icon
		end
		if path ~= nil then
			local sp = CCSprite:create(path)
			sp:setScale(0.7)
			sp:setPositionX(posX)
			self._ccbOwner.node_awards:addChild(sp)
			posX = posX + 25

		    local label = CCLabelTTF:create("+"..((starConfig.reward_coefficient or 0)*100).."%", global.font_default, 20)
		    label:setColor(ccc3(232, 161, 0))
		    label:setAnchorPoint(ccp(0,0.5))
		    label = setShadow5(label)
		    label:setPositionX(posX)
		    self._ccbOwner.node_awards:addChild(label)
		    posX = posX + label:getContentSize().width + 25 + 10
		end
	end
end

--设置左边的进度显示
function QUIDialogSparField:setStep(step, status)
	for i=1,5 do
		local sp = self._ccbOwner["step"..i]
		local texture = nil
		local paths = QResPath("spar_progress_dot")
		if i < step then
			texture = CCTextureCache:sharedTextureCache():addImage(paths[1])
		elseif i == step then
			if status == remote.sparField.STATUS_FIGHT then
				texture = CCTextureCache:sharedTextureCache():addImage(paths[3])
			elseif status == remote.sparField.STATUS_END then
				texture = CCTextureCache:sharedTextureCache():addImage(paths[1])
			else
				if self._isFighter then
					texture = CCTextureCache:sharedTextureCache():addImage(paths[1])
				else
					texture = CCTextureCache:sharedTextureCache():addImage(paths[2])
				end
			end
		elseif i > step then
			texture = CCTextureCache:sharedTextureCache():addImage(paths[2])
		end
		sp:setTexture(texture)
		local size = texture:getContentSize()
		local rect = CCRectMake(0, 0, size.width, size.height)
		sp:setTextureRect(rect)
	end
end

--领取最后的大宝箱
function QUIDialogSparField:getFinalReward()
	local fireFun = function (chestEffect)
		local makeFire = function (x,y)
			local firePlayer = QUIWidgetAnimationPlayer.new()
			firePlayer:setPosition(ccp(x,y))
			self:getView():addChild(firePlayer)
			firePlayer:playAnimation("ccb/effects/zhanchang_yanhuo_001.ccbi",nil,function ()
				firePlayer:removeFromParent()
			end)
		end
		local fires = {{x = 20, y = 150, time = 0}, {x = 310, y = 53, time = 0.35}, {x = 270, y = -177, time = 0.70}, {x = -250, y = 123, time = 1}, {x = -60, y = 113, time = 1.3}}
		local maxTime = 0
		for _,fire in ipairs(fires) do
			if maxTime < fire.time then
				maxTime = fire.time
			end
			if fire.time > 0 then
				local handler = scheduler.performWithDelayGlobal(function ()
					makeFire(fire.x, fire.y)
				end, fire.time)
				table.insert(self._schedulerHandlers, handler)
			else
				makeFire(fire.x, fire.y)
			end
		end
		local handler = scheduler.performWithDelayGlobal(function ()
			chestEffect:removeFromParent()
			local endEffect = QUIWidgetAnimationPlayer.new()
			endEffect:setPositionY(-100)
			self:getView():addChild(endEffect)
			endEffect:playAnimation("ccb/effects/widget_spar_boss2.ccbi",nil,function ()
				endEffect:removeFromParent()
				self:sparFieldStep(false)
			end)
		end, maxTime + 1)
		table.insert(self._schedulerHandlers, handler)
	end


	local chestEffect = QUIWidgetAnimationPlayer.new()
	chestEffect:setPositionY(-100)
	self:getView():addChild(chestEffect)
	chestEffect:playAnimation("ccb/effects/Dialog_sparfield_baoxiang_001.ccbi",nil,function ()
		self._clickBackHandler = function ( ... )
			remote.sparField:sparFieldGetFinalRewardRequest(function (data)
				self._clickBackHandler = nil
				chestEffect:disappear()
				chestEffect:playAnimation("ccb/effects/Dialog_sparfield_baoxiang_001.ccbi",nil,function ()
					local awardStr = data.sparFieldGetFinalRewardResponse.finalReward
					local awards = {}
					awardStr = string.split(awardStr, ";")
					for _,str in ipairs(awardStr) do
						if str ~= "" then
							local v = string.split(str, "^")
							local count = tonumber(v[2])
							local typeName = remote.items:getItemType(v[1])
							local id = nil
							if typeName == nil then
								typeName = ITEM_TYPE.ITEM
								id = tonumber(v[1])
							end
							table.insert(awards, {id = id, typeName = typeName, count = count or 0})
						end
					end
					local myInfo = remote.sparField:getSparFieldMyInfo()
			  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
			    		options = {awards = awards, callBack = function ()
							-- self:sparFieldStep(false)
							fireFun(chestEffect)
			    		end}},{isPopCurrentDialog = false} )
			   		dialog:setTitle("恭喜您获得"..(myInfo.startCount or 0).."星宝箱奖励")
				end,false,"open")
			end)
		end
	end,false,"normal")
end

--显示最终的界面
function QUIDialogSparField:showFinal()
	self._isFinal = true
	self._ccbOwner.node_empty:setVisible(true)
	self._ccbOwner.node_npc:removeAllChildren()
	local npcAvatar = QUIWidgetActorDisplay.new(10056)
	npcAvatar:setScaleX(-1.5)
	npcAvatar:setScaleY(1.5)
	self._ccbOwner.node_npc:addChild(npcAvatar)
	self._ccbOwner.tf_desc:setString("魂师大人，您今天已全部通关，每日5点刷新。")
end

--点击背景前进
function QUIDialogSparField:_backClickHandler(event)
	if self._arrowActionHandler ~= nil then
		remote.sparField:sparFieldPassWaveRequest(self._waveId, self._isFighter, function ()
			self:stopArrowAnimation()
			self:playMoveAnimation(function ()
				self:sparFieldStep(false)
			end)
		end)	
	elseif self._clickBackHandler ~= nil then

		if event.x > 430 and event.x < 760 and event.y > 210 and event.y < 420 then
			self._clickBackHandler()	
		end
	end
end

--帮助
function QUIDialogSparField:_onTriggerRule()
    app.sound:playSound("common_small")
  	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSparFieldHelp"})
end

--刷新传奇魂师
function QUIDialogSparField:_onTriggerRefresh()
    app.sound:playSound("common_small")
    if self._isFinal == true then
    	app.tip:floatTip("魂师大人，今日晶石幻境已经通关，没必要刷新战神啦~")
    	return
    end
	local myInfo = remote.sparField:getSparFieldMyInfo()
	local refreshCount = myInfo.legendHeroRefreshCount or 1
	local tokenConsume = QStaticDatabase:sharedDatabase():getTokenConsume("spar_legend_hero_refresh", refreshCount)
	if tokenConsume.money_num > remote.user.token then
		QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
		return
	end
	remote.sparField:sparFieldRefreshLegendHerosRequest(function ()
		self:showMyInfo(true)
	end)
end

--进入排行榜
function QUIDialogSparField:_onTriggerRank()
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRank", 
		options = {initRank = "sparFieldRank"}}, 
		{isPopCurrentDialog = false})
end

--提示传奇魂师
function QUIDialogSparField:_onTriggerHeroTips()
	app.tip:floatTip("出现在今日战神中的魂师，会大幅提升战力。刷新可提高队伍中出现战神的数量～")
end

--进入商店
function QUIDialogSparField:_onTriggerShop()
    app.sound:playSound("common_small")
	remote.stores:openShopDialog(SHOP_ID.sparShop)
end

--进入战斗
function QUIDialogSparField:fightClickHandler(event)
    app.sound:playSound("common_small")
    local fightInfo = event.fightInfo
    self:startBattle(fightInfo, event.difficulty)
end

--退出战斗的时候
function QUIDialogSparField:exitFromBattleHandler()
	remote.sparField:setInBattle(false)
	local status,waveId,isFighter = remote.sparField:getStatus()

  	if status == remote.sparField.STATUS_GO then
		self:playMoveAnimation(nil, false)

		local callback = function ()
			self:playFightOutAnimation()
			self:enableTouchSwallowTop()
			self._handler = scheduler.performWithDelayGlobal(function ()
				self:disableTouchSwallowTop()
				self:removeAllFighters()
				if waveId == remote.sparField.FINAL_WAVE then --如果是最终的关卡请求一下前进，然后走开大宝箱
					remote.sparField:sparFieldPassWaveRequest(self._waveId, self._isFighter, function ()
						self:sparFieldStep(false)
					end)
				else
					self:playBackAnimation(function ()
						self:sparFieldStep(false)
					end)
				end

				--为了实现星星的一个的动画
				local starOffset = remote.sparField:getFightStarCount()
				local myInfo = remote.sparField:getSparFieldMyInfo()
				local todayStarCount = myInfo.startCount or 0
				self._ccbOwner.tf_star_count:setString(todayStarCount)
				local arr = CCArray:create()
				arr:addObject(CCScaleTo:create(0.1, 1.2, 1.2))
				arr:addObject(CCScaleTo:create(0.15, 0.9, 0.9))
				arr:addObject(CCScaleTo:create(0.1, 1.05, 1.05))
				arr:addObject(CCScaleTo:create(0.05, 1, 1))
				self._ccbOwner.tf_star_count:runAction(CCSequence:create(arr))

		      	local numEffect = QUIWidgetAnimationPlayer.new()
		      	self._ccbOwner.tf_star_count:getParent():addChild(numEffect)
		      	numEffect:setPositionX(-70)
		      	numEffect:playAnimation("effects/Tips_add.ccbi", function(ccbOwner)
		            ccbOwner.content:setString(" +" .. math.abs(starOffset))
		        end)
			end,0.5)
		end
		if remote.sparField:checkLevelUp() == true then
		  	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSparFieldLevelUp",
		    	options = {sparLevel = self._sparLevel, callback = callback}})
	  	else
		  	callback()
	  	end
	end
end

function QUIDialogSparField:startBattle(fightInfo, difficulty)
	local sparFieldArrangement = QSparFieldArrangement.new({fightInfo = fightInfo, waveId = self._waveId, difficulty = difficulty})
    sparFieldArrangement:setIsLocal(true)
	local teams = sparFieldArrangement:getExistingHeroes()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMetalCityTeamArrangement",
	options = {arrangement = sparFieldArrangement, isShowQuickBtn = true, isShowQuickBtn = (#teams > 0)}})
end

return QUIDialogSparField