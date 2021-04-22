--
-- Author: Kumo
-- Date: Tue Mar  8 20:53:39 2016
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSunWarPlayerInfo = class("QUIWidgetSunWarPlayerInfo", QUIWidget)
local QUIWidgetActorDisplay = import(".actorDisplay.QUIWidgetActorDisplay")
local QUIWidgetActorActivityDisplay = import(".actorDisplay.QUIWidgetActorActivityDisplay")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetHeroTitleBox = import("..widgets.QUIWidgetHeroTitleBox")
local QChatDialog = import("...utils.QChatDialog")
local QStaticDatabase = import("...controllers.QStaticDatabase")

QUIWidgetSunWarPlayerInfo.PASS = "PASS"
QUIWidgetSunWarPlayerInfo.NOW = "NOW"
QUIWidgetSunWarPlayerInfo.FUTURE = "FUTURE"

QUIWidgetSunWarPlayerInfo.EVENT_AVATAR_CLICK = "EVENT_AVATAR_CLICK"
QUIWidgetSunWarPlayerInfo.EVENT_INFO_CLICK = "EVENT_INFO_CLICK"
QUIWidgetSunWarPlayerInfo.EVENT_FAST_FIGHT_CLICK = "EVENT_FAST_FIGHT_CLICK"
QUIWidgetSunWarPlayerInfo.EVENT_AUTO_FIGHT_CLICK = "EVENT_AUTO_FIGHT_CLICK"

function QUIWidgetSunWarPlayerInfo:ctor(options)
	local ccbFile = "ccb/Widget_SunWar_PlayerInfo.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerAvatar", callback = handler(self, QUIWidgetSunWarPlayerInfo._onTriggerAvatar)},
		{ccbCallbackName = "onTriggerInfo", callback = handler(self, QUIWidgetSunWarPlayerInfo._onTriggerInfo)},
		{ccbCallbackName = "onTriggerInfoBig", callback = handler(self, QUIWidgetSunWarPlayerInfo._onTriggerInfo)},
		{ccbCallbackName = "onTriggerFastFighter", callback = handler(self, QUIWidgetSunWarPlayerInfo._onTriggerFastFighter)},
		{ccbCallbackName = "onTriggerAutoFighter", callback = handler(self, QUIWidgetSunWarPlayerInfo._onTriggerAutoFighter)},
    }
	QUIWidgetSunWarPlayerInfo.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._waveID = options.waveID or 0
	self._heroInfo = options.heroInfo or {}
	self._currentState = options.state or QUIWidgetSunWarPlayerInfo.FUTURE
	self._isShowFastBtn = options.fastFight or false
	self._avatarHero = nil
	self._ccbam = nil
	self._actorID = 0

	self._isPlaying = false
	
	self:_init()
end

function QUIWidgetSunWarPlayerInfo:onEnter()
	-- self._isPlaying = false
	-- print("[Kumo] QUIWidgetSunWarPlayerInfo:onEnter")
end

function QUIWidgetSunWarPlayerInfo:onExit()
	self._isPlaying = false
	-- print("[Kumo] QUIWidgetSunWarPlayerInfo:onExit")
	if self._talkHandler ~= nil then
		scheduler.unscheduleGlobal(self._talkHandler)
		self._talkHandler = nil
	end
end

function QUIWidgetSunWarPlayerInfo:_init()
	-- print("[Kumo] QUIWidgetSunWarPlayerInfo:_init", self._waveID)
	self._ccbOwner.node_gravestone:setVisible(false)
	self._ccbOwner.node_avatar_content:setVisible(false)
	self._ccbOwner.node_avatar:setVisible(false)
	self._ccbOwner.node_avatar_ani:setVisible(false)
	self._ccbOwner.node_info:setVisible(false)
	self._ccbOwner.node_total_hp:setVisible(false)
	-- self._ccbOwner.node_avatar_ani:removeAllChildren()
	-- self._ccbOwner.node_avatar:removeAllChildren()

	self._ccbam = tolua.cast(self:getCCBView():getUserObject(), "CCBAnimationManager")
	self._ccbam:runAnimationsForSequenceNamed("static")


	local avatarHeroInfo = remote.sunWar:getAvatarHeroInfoByWaveID(self._waveID)
	if avatarHeroInfo then
		self._actorID = avatarHeroInfo.actorId
		if avatarHeroInfo.defaultActorId and avatarHeroInfo.defaultActorId ~= 0 then
			self._actorID = avatarHeroInfo.defaultActorId
		end
		-- self._actorDisplay = QUIWidgetActorActivityDisplay.new(avatarHeroInfo.actorId, {heroInfo = {skinId = avatarHeroInfo.skinId}})
		-- self._ccbOwner.node_avatar_ani:addChild(self._actorDisplay)

		self:showTitle(avatarHeroInfo.title, avatarHeroInfo.soulTrial)
	end

	self._initTotalHpScaleX = self._ccbOwner.total_hp:getScaleX()
end

function QUIWidgetSunWarPlayerInfo:setWaveID( int )
	self._waveID = int
end
 
function QUIWidgetSunWarPlayerInfo:updateState( str )
	self._ccbOwner.btn_fast_fight:setVisible(false)
	self._ccbOwner.node_reduce_effect:setVisible(false)
	self._ccbOwner.btn_auto_fight:setVisible(false)
	self._ccbOwner.node_auto_reduce_effect:setVisible(false)

	self._currentState = str
	if self._talkHandler ~= nil then
		scheduler.unscheduleGlobal(self._talkHandler)
		self._talkHandler = nil
	end
	if str == QUIWidgetSunWarPlayerInfo.PASS then
		self:_showPass()
		self:removeWord()
	elseif str == QUIWidgetSunWarPlayerInfo.NOW then
		self:_showNow()
		if remote.sunWar:checkSunWarWaveCanFastFight(self._waveID) == true then
			self._ccbOwner.btn_fast_fight:setVisible(true)
			self._ccbOwner.node_reduce_effect:setVisible(app.tip:checkReduceUnlokState("sunWarFastBattl"))
		elseif remote.sunWar:checkSunWarWaveCanAutoFight() then
			self._ccbOwner.btn_auto_fight:setVisible(true)

			self._ccbOwner.node_auto_reduce_effect:setVisible(app.tip:checkReduceUnlokState("sunWarAutoBattle"))
		end
	else
		self:_showFuture()
	end
end

function QUIWidgetSunWarPlayerInfo:_showPass()
	-- print("[Kumo] QUIWidgetSunWarPlayerInfo:_showPass() ", self._waveID, self._isPlaying)
	-- if self._isPlaying then return end

	local currentMapID = remote.sunWar:getCurrentMapID()

	local currentWaveID = remote.sunWar:getCurrentWaveID()
	local isHeroFirstAppearance = remote.sunWar:getIsHeroFirstAppearance()
	local waveInfo = remote.sunWar:getWaveInfoByWaveID( self._waveID )
	if waveInfo == nil then
		return
	end

	local needMapID = remote.sunWar:getMapIDWithLastWaveID( self._waveID )
	self:_hideBattleIng()
	self:_showBossBuff(false)

	if needMapID ~= currentMapID then 
		self:_showFuture()
		return 
	end

	if self._waveID + 1 == currentWaveID and isHeroFirstAppearance then
		self._ccbOwner.node_gravestone:setVisible(false)
		self:_showTotalHp()
		
		if not self._actorDisplay then
			local avatarHeroInfo = remote.sunWar:getAvatarHeroInfoByWaveID(self._waveID)
			self._actorID = avatarHeroInfo.actorId
			if avatarHeroInfo.defaultActorId and avatarHeroInfo.defaultActorId ~= 0 then
				self._actorID = avatarHeroInfo.defaultActorId
			end
			self._actorDisplay = QUIWidgetActorActivityDisplay.new(avatarHeroInfo.actorId, {heroInfo = {skinId = avatarHeroInfo.skinId}})
			self._ccbOwner.node_avatar_ani:addChild(self._actorDisplay)

			self:showTitle(avatarHeroInfo.title, avatarHeroInfo.soulTrial)
		end
		self._actorDisplay:stopDisplay()

		self._ccbOwner.node_avatar_content:setVisible(true)
		self._ccbOwner.node_avatar_ani:setVisible(true)
		self._ccbOwner.node_avatar:setVisible(false)
		self._isPlaying = true
		if waveInfo.index == 9 then
			remote.sunWar:setIsHeroFirstAppearance( false )
		end
		self._actorDisplay:displayWithBehavior(ANIMATION_EFFECT.DEAD)
		self._actorDisplay:setDisplayBehaviorCallback(function ()
			self._actorDisplay:setDisplayBehaviorCallback(nil)
			self._ccbOwner.node_gravestone:setVisible(true)
			self._ccbOwner.node_avatar_content:setVisible(false)
			self._ccbOwner.node_avatar:setVisible(false)
			self._ccbOwner.node_avatar_ani:removeAllChildren()
			self._actorDisplay = nil
			self._ccbOwner.sp_firstWin:setVisible(false)
			self._ccbOwner.chenghao:removeAllChildren()
			self._isPlaying = false
		end)
	else
		self._ccbOwner.node_gravestone:setVisible(true)
		self._ccbOwner.node_avatar_content:setVisible(false)
		self._ccbOwner.node_avatar:setVisible(false)
		self._ccbOwner.node_avatar_ani:setVisible(false)
		self._ccbOwner.sp_firstWin:setVisible(false)
		self._ccbOwner.chenghao:removeAllChildren()
	end

	self._ccbOwner.node_info:setVisible(true)

	local name = remote.sunWar:getPlayerNameByWaveID(self._waveID)
	self._ccbOwner.tf_user_name:setString(name)
	local force = remote.sunWar:getPlayerForceByWaveID(self._waveID, true)
	local num,unit = q.convertLargerNumber(force or 0)
	self._ccbOwner.tf_battleforce_value:setString(num..(unit or ""))
	
	self._ccbOwner.tf_wave_value:setString(currentMapID.."-"..waveInfo.index)
end

function QUIWidgetSunWarPlayerInfo:_showNow()
	if self._avatarHero then 
		self:_showBattleIng() 
		-- print("魂师已出场，刷新总血量")
		self:_showTotalHp()
		return 
	end

	if self._isPlaying then return end

	local isHeroFirstAppearance = remote.sunWar:getIsHeroFirstAppearance()
	local name = remote.sunWar:getPlayerNameByWaveID(self._waveID)
	local force = remote.sunWar:getPlayerForceByWaveID(self._waveID, true)
	local avatarHeroInfo = remote.sunWar:getAvatarHeroInfoByWaveID(self._waveID)

	self._ccbOwner.node_gravestone:setVisible(false)
	self._ccbOwner.node_avatar_content:setVisible(true)
	self._ccbOwner.node_avatar_ani:setVisible(isHeroFirstAppearance)
	self._ccbOwner.node_avatar:setVisible(not isHeroFirstAppearance)
	self._ccbOwner.node_info:setVisible(not isHeroFirstAppearance)
	self._ccbOwner.node_total_hp:setVisible(not isHeroFirstAppearance)

	self._ccbOwner.tf_user_name:setString(name)

	local num,unit = q.convertLargerNumber(force or 0)
	self._ccbOwner.tf_battleforce_value:setString(num..(unit or ""))
	
	local waveInfo = remote.sunWar:getWaveInfoByWaveID( self._waveID )
	local currentMapID = remote.sunWar:getCurrentMapID()
	self._ccbOwner.tf_wave_value:setString(currentMapID.."-"..waveInfo.index)

	if not avatarHeroInfo then self:_showFuture() return end
	
	if isHeroFirstAppearance then
		-- 初次登场，播放特效
		if not self._actorDisplay then
			local avatarHeroInfo = remote.sunWar:getAvatarHeroInfoByWaveID(self._waveID)
			self._actorID = avatarHeroInfo.actorId
			if avatarHeroInfo.defaultActorId and avatarHeroInfo.defaultActorId ~= 0 then
				self._actorID = avatarHeroInfo.defaultActorId
			end
			self._actorDisplay = QUIWidgetActorActivityDisplay.new(avatarHeroInfo.actorId, {heroInfo = {skinId = avatarHeroInfo.skinId}})
			self._ccbOwner.node_avatar_ani:addChild(self._actorDisplay)

			self:showTitle(avatarHeroInfo.title, avatarHeroInfo.soulTrial)
		end
		self._actorDisplay:stopDisplay()
		remote.sunWar:setIsHeroFirstAppearance( false )
		self._isPlaying = true
		self._actorDisplay:displayWithBehavior(ANIMATION_EFFECT.ULTRA_VICTORY_WITHDELAY)
		self._actorDisplay:setDisplayBehaviorCallback(function ()
			self._actorDisplay:setDisplayBehaviorCallback(nil)
			self._actorDisplay:displayWithBehavior(ANIMATION_EFFECT.VICTORY)
			self._ccbOwner.node_info:setVisible(true)
			-- 先显示血条
			self:_showBattleIng()
			self:_showTotalHp( true )
			self:_showFirstWin()

			self._actorDisplay:setDisplayBehaviorCallback(function ()
				self._actorDisplay:setDisplayBehaviorCallback(nil)
				self:startTalk(waveInfo.index)
				self:_showBossBuff()
		        self._isPlaying = false
			end)
		end)
	else
		self._ccbam:runAnimationsForSequenceNamed("static")
		self._actorID = avatarHeroInfo.actorId
		if avatarHeroInfo.defaultActorId and avatarHeroInfo.defaultActorId ~= 0 then
			self._actorID = avatarHeroInfo.defaultActorId
		end
		self._avatarHero = QUIWidgetActorDisplay.new(avatarHeroInfo.actorId, {heroInfo = {skinId = avatarHeroInfo.skinId}})
		self._ccbOwner.node_avatar:addChild(self._avatarHero)
		self:_showBattleIng()
		self:_showTotalHp()

		self:showTitle(avatarHeroInfo.title, avatarHeroInfo.soulTrial)
		self:startTalk(waveInfo.index)
		self:_showFirstWin()
		self:_showBossBuff()
	end
end

function QUIWidgetSunWarPlayerInfo:_showBossBuff( isShow )
	if isShow == false then 
		self._ccbOwner.node_base_effect:setVisible(false)
		return
	end
	local startWaveID = remote.sunWar:getStartWaveID() 
	if not startWaveID or startWaveID < 1 then
		startWaveID = 1
	end
	local startMapID = remote.sunWar:getMapIDWithLastWaveID(startWaveID)
	local curMapID = remote.sunWar:getCurrentMapID()
	local todayPassedWaves = remote.sunWar:getTodayPassedWaves()
	if curMapID > startMapID and q.isEmpty(todayPassedWaves) == false and #todayPassedWaves >= 9 then
		local _, ccbFile = remote.sunWar:getBossBuffURL()
		local effect = QUIWidgetAnimationPlayer.new()
		effect:playAnimation(ccbFile, nil, nil, false)
		self._ccbOwner.node_base_effect:removeAllChildren()
		self._ccbOwner.node_base_effect:addChild(effect)
		self._ccbOwner.node_base_effect:setVisible(true)
	else
		self._ccbOwner.node_base_effect:setVisible(false)
	end
end

function QUIWidgetSunWarPlayerInfo:_showFirstWin()
	local currentWaveID = remote.sunWar:getCurrentWaveID() or 1
	local lastPassWave = remote.sunWar:getLastPassedWave() or 0
	if currentWaveID > lastPassWave then
		self._ccbOwner.sp_firstWin:setVisible(true)
	else
		self._ccbOwner.sp_firstWin:setVisible(false)
	end
end

function QUIWidgetSunWarPlayerInfo:startTalk(index)
	local config = QStaticDatabase:sharedDatabase():getBattlefieldLangaueByIndex(index)
	self._words = {}
	if config ~= nil then
		for i=1,3 do
			if config["langaue_"..i] ~= nil then
				table.insert(self._words, config["langaue_"..i])
			end
		end
	end
	if #self._words > 0 then
		self:showWord(self._words[math.random(#self._words)])
		if self._talkHandler ~= nil then
			scheduler.unscheduleGlobal(self._talkHandler)
			self._talkHandler = nil
		end
		self._talkHandler = scheduler.scheduleGlobal(function ()
			if self._words then
				self:showWord(self._words[math.random(#self._words)])
			end
		end, 6)
	end
end

function QUIWidgetSunWarPlayerInfo:_showFuture()
	self._ccbOwner.node_gravestone:setVisible(false)
	self._ccbOwner.node_avatar_content:setVisible(false)
	self._ccbOwner.node_avatar:setVisible(false)
	self._ccbOwner.node_avatar_ani:setVisible(false)
	self._ccbOwner.node_info:setVisible(false)
	self._ccbam:runAnimationsForSequenceNamed("static")
	self:_hideBattleIng()
	self:_showBossBuff(false)
end

function QUIWidgetSunWarPlayerInfo:_showBattleIng()
	if self._battleIng then return end

	local pos, ccbFile = remote.sunWar:getBattleIngURL()
	self._battleIng = QUIWidgetAnimationPlayer.new()
	self._ccbOwner.node_battle_ing:addChild(self._battleIng)
	self._battleIng:setScale(0.7)
	self._ccbOwner.node_battle_ing:setPosition(ccp(0, remote.sunWar:getAvatarHeightByActorID( self._actorID )))
		
	local effectFun = function()
		self._battleIng:playAnimation(ccbFile, nil, nil, false)
	end

	effectFun()
end

function QUIWidgetSunWarPlayerInfo:_hideBattleIng()
	if not self._battleIng then return end
	self._battleIng:stopAnimation()
	self._battleIng:disappear()
	self._battleIng = nil
end

function QUIWidgetSunWarPlayerInfo:_showTotalHp( boo )
	local currentWaveID = remote.sunWar:getCurrentWaveID()
	if self._waveID ~= currentWaveID then 
		-- NPC空血
		self._ccbOwner.total_hp:setScaleX( 0 )
		return
	end
	self._ccbOwner.node_total_hp:setVisible(true)
	if boo then 
		-- NPC满血
		self._ccbOwner.total_hp:setScaleX( self._initTotalHpScaleX )
		return
	end

	local npcTbl = remote.sunWar:getNpcHeroInfo()
	if not npcTbl or table.nums(npcTbl) == 0 then
		-- NPC满血
		self._ccbOwner.total_hp:setScaleX( self._initTotalHpScaleX )
		return
	end
	local waveFighter = remote.sunWar:getWaveFigtherByWaveID(self._waveID)
	local totalMaxHp = 0
	for _, hero in pairs( waveFighter.heros ) do
		totalMaxHp = totalMaxHp + remote.sunWar:getNpcHeroMaxHp( hero.actorId, waveFighter )
	end
	if totalMaxHp == 0 then
		totalMaxHp = 1
	end
	
	local totalHp = 0
	for _, hero in pairs( npcTbl ) do
		if not hero.currHp then
			totalHp = totalHp + remote.sunWar:getNpcHeroMaxHp( hero.actorId, waveFighter )
		else
			totalHp = totalHp + hero.currHp
		end
	end

	local sx = math.min(totalHp / totalMaxHp, 1) * self._initTotalHpScaleX
	self._ccbOwner.total_hp:setScaleX( sx )
end

function QUIWidgetSunWarPlayerInfo:showTitle(title, soulTrial)
	-- 海神岛不显示称号
 	-- local titleBox = QUIWidgetHeroTitleBox.new()
	-- titleBox:setTitleId(title, soulTrial)
	-- self._ccbOwner.chenghao:removeAllChildren()
	-- self._ccbOwner.chenghao:addChild(titleBox)
end

function QUIWidgetSunWarPlayerInfo:removeWord()
	if self._wordWidget ~= nil then
		self._wordWidget:removeFromParent()
		self._wordWidget = nil
	end
end

--设置是否禁言
function QUIWidgetSunWarPlayerInfo:setGag(b)
	self._isGag = b
end

function QUIWidgetSunWarPlayerInfo:showWord(str)
	if self._isGag == true then return end --禁言状态不准说话
	self:removeWord()
	local word = "啦啦啦！啦啦啦！我是卖报的小行家！"
	if str ~= nil then
		word = str
	elseif self.info ~= nil and self.info.declaration ~= nil and self.info.declaration ~= "" then
		word = self.info.declaration
	elseif self._words ~= nil then
		local maxCount = table.nums(self._words)
		local count = math.random(1, maxCount)
		for _,value in pairs(self._words) do
			if value.id == count then
				word = value.langaue
				break
			end
		end
	end
	self._wordWidget = QChatDialog.new()
	self:addChild(self._wordWidget)
	self._wordWidget:setString(word)

	local size = self._wordWidget:getContentSize()
	local pos = self._wordWidget:convertToWorldSpace(ccp(0,0))
	if (pos.x + size.width) > display.width then
		self._wordWidget:setPosition(ccp(-50, 130))
		self._wordWidget:setScaleX(-1)
	else
		self._wordWidget:setScaleX(1)
		self._wordWidget:setPosition(ccp(50, 130))
	end
end

function QUIWidgetSunWarPlayerInfo:_onTriggerAvatar()
	local waveID = remote.sunWar:getCurrentWaveID()
	
	if waveID ~= self._waveID then return end
	self:dispatchEvent({name = QUIWidgetSunWarPlayerInfo.EVENT_AVATAR_CLICK, waveID = self._waveID})
end


function QUIWidgetSunWarPlayerInfo:_onTriggerInfo()
	self:dispatchEvent({name = QUIWidgetSunWarPlayerInfo.EVENT_INFO_CLICK, waveID = self._waveID})
end

function QUIWidgetSunWarPlayerInfo:_onTriggerFastFighter()
	if app.unlock:getUnlockSunWarFastFight(true) == false then return end 
	self._isPlaying = false

	if app.tip:checkReduceUnlokState("sunWarFastBattl") then
		app.tip:setReduceUnlockState("sunWarFastBattl", 2)
		self._ccbOwner.node_reduce_effect:setVisible(false)
	end
	self:dispatchEvent({name = QUIWidgetSunWarPlayerInfo.EVENT_FAST_FIGHT_CLICK, waveID = self._waveID})
end

function QUIWidgetSunWarPlayerInfo:_onTriggerAutoFighter()
	if app.tip:checkReduceUnlokState("sunWarAutoBattle") then
		app.tip:setReduceUnlockState("sunWarAutoBattle", 2)
		self._ccbOwner.node_auto_reduce_effect:setVisible(false)
	end
	
	self:dispatchEvent({name = QUIWidgetSunWarPlayerInfo.EVENT_AUTO_FIGHT_CLICK, waveID = self._waveID})
end

return QUIWidgetSunWarPlayerInfo