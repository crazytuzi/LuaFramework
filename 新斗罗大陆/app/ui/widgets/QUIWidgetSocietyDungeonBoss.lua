--
-- Author: Kumo.Wang
-- Date: Tue May 24 19:01:52 2016
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSocietyDungeonBoss = class("QUIWidgetSocietyDungeonBoss", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetActorDisplay = import(".actorDisplay.QUIWidgetActorDisplay")
local QUIWidgetActorActivityDisplay = import(".actorDisplay.QUIWidgetActorActivityDisplay")
local QUIViewController = import("..QUIViewController")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")

QUIWidgetSocietyDungeonBoss.EVENT_CLICK = "QUIWIDGETSOCIETYDUNGEONBOSS_EVENT_CLICK"
QUIWidgetSocietyDungeonBoss.EVENT_ROBOT = "QUIWIDGETSOCIETYDUNGEONBOSS_EVENT_ROBOT"
QUIWidgetSocietyDungeonBoss.EVENT_DEAD = "QUIWIDGETSOCIETYDUNGEONBOSS_EVENT_DEAD"

function QUIWidgetSocietyDungeonBoss:ctor(options, isFinalBoss)
	local ccbFile = "ccb/Widget_Society_BossInfo.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, QUIWidgetSocietyDungeonBoss._onTriggerClick)},
		{ccbCallbackName = "onTriggerRobot", callback = handler(self, QUIWidgetSocietyDungeonBoss._onTriggerRobot)},
	}
	QUIWidgetSocietyDungeonBoss.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    
	self._curHp = options.bossHp
	self._chapter = options.chapter
	self._wave = options.wave
	self._isSetting = options.isSetting or false
	self._isFinalBoss = isFinalBoss
	self.fcaAnimation = nil
	self._isDead = true
	self._isCurTarget = false -- 是不是可以被攻击的目标（前置条件解锁了吗）

	self._scoietyWaveConfig = QStaticDatabase.sharedDatabase():getScoietyWave(self._wave, self._chapter)
	-- print("[Kumo] QUIWidgetSocietyDungeonBoss:ctor() ", self._chapter, self._wave, self._scoietyWaveConfig)
	if not self._scoietyWaveConfig then
		return nil
	end
	-- QPrintTable(self._scoietyWaveConfig)
	self._bossId = self._scoietyWaveConfig.boss
	self._bossScale = self._scoietyWaveConfig.boss_scale

	if not self._isSetting then
		self._bossLevel = self._scoietyWaveConfig.levels
		self._initTotalHpScaleX = self._ccbOwner.sp_hp:getScaleX()
	else
		self._ccbOwner.sp_recommend:setVisible(false)
		self._ccbOwner.sp_dead:setVisible(false)
	end

	self._ccbOwner.node_hp:setVisible(false)
	self._ccbOwner.node_btn_fastFighter:setVisible(false)

	self:_init()
end

function QUIWidgetSocietyDungeonBoss:onEnter()

end

function QUIWidgetSocietyDungeonBoss:onExit()

end

function QUIWidgetSocietyDungeonBoss:setRecommend(b)
	-- self._ccbOwner.sp_recommend:setVisible(b)
	self._ccbOwner.sp_recommend:setVisible(false)
	if b then
		if not self._widgetBattleing then
			self._widgetBattleing = QUIWidget.new("ccb/effects/battle_ing.ccbi")
			self._widgetBattleing:setPosition(ccp(self._ccbOwner.sp_recommend:getPosition()))
			self._widgetBattleing:setScale(0.5)
		    self._ccbOwner.sp_recommend:getParent():addChild(self._widgetBattleing)
	   	end
   	else
   		if self._widgetBattleing then
   			self._widgetBattleing:removeFromParent()
   			self._widgetBattleing:onExit()
   			self._widgetBattleing = nil
   		end
	end
end

function QUIWidgetSocietyDungeonBoss:setFocuseNum(int)
	if not int or int == "" then int = 0 end
	self._focuseIndex = int
	if self._focuseIndex > 0 then
		self._ccbOwner.tf_focuse:setString(self._focuseIndex)
	else
		self._ccbOwner.tf_focuse:setString("")
	end
end

function QUIWidgetSocietyDungeonBoss:getFocuseNum()
	return self._focuseIndex or 0
end

-- function QUIWidgetSocietyDungeonBoss:setIsSetting(b)
-- 	self._isSetting = b
-- end
-- function QUIWidgetSocietyDungeonBoss:getIsSetting(b)
-- 	return self._isSetting
-- end

function QUIWidgetSocietyDungeonBoss:updateHp( curHp, skipDeadAni )
	print("[Kumo] QUIWidgetSocietyDungeonBoss:updateHp() ", self._isSetting)
	if self._isSetting then return end

	if curHp then self._curHp = curHp end

	local curProportion = 1
	if not self._percentBarClippingNode then
		self._percentBarClippingNode = q.newPercentBarClippingNode(self._ccbOwner.sp_hp)
		self._totalStencilWidth = self._ccbOwner.sp_hp:getContentSize().width * self._ccbOwner.sp_hp:getScaleX()
	end
	if self._isFinalBoss ~= true then
		local totalHp = self:getTotalHp( self._bossId, self._bossLevel )
		curProportion = self._curHp / totalHp
	end
	local stencil = self._percentBarClippingNode:getStencil()
    stencil:setPositionX(-self._totalStencilWidth + curProportion*self._totalStencilWidth)
 --    --原逻辑
	-- if self._curHp > 0 or self._isFinalBoss then
	-- 	self._isDead = false
	-- 	self._ccbOwner.sp_dead:setVisible(false)
	-- 	self._ccbOwner.node_boss:setVisible(true)
	-- 	-- self._ccbOwner.node_hp:setVisible(true)
	-- 	self._ccbOwner.node_name:setVisible(true)
	-- else
	-- 	-- print("QUIWidgetSocietyDungeonBoss:updateHp() ", self._wave, self._isPlaying, self._isDead)
	-- 	self._ccbOwner.node_hp:setVisible(false)

	-- 	if not self._isDead and not skipDeadAni then
	-- 		self:_showDead()
	-- 		self._isDead = true
	-- 	else
	-- 		if not self._isPlaying then
	-- 			self._ccbOwner.sp_dead:setVisible(true)
	-- 			self._ccbOwner.node_boss:setVisible(false)
	-- 			self._ccbOwner.node_name:setVisible(false)
	-- 			self._isDead = true
	-- 		end
	-- 	end
	-- end


	if self._curHp > 0 then
		self._isDead = false
		self._ccbOwner.sp_dead:setVisible(false)
		self._ccbOwner.node_boss:setVisible(true)
		-- self._ccbOwner.node_hp:setVisible(true)
		self._ccbOwner.node_name:setVisible(true)
	elseif self._isFinalBoss then
		self._isDead = true
		self._ccbOwner.sp_dead:setVisible(false)
		self._ccbOwner.node_boss:setVisible(true)
		self._ccbOwner.node_name:setVisible(true)
		return false
	else
		self._ccbOwner.node_hp:setVisible(false)

		if not self._isDead and not skipDeadAni then
			self:_showDead()
			self._isDead = true
		else
			if not self._isPlaying then
				self._ccbOwner.sp_dead:setVisible(true)
				self._ccbOwner.node_boss:setVisible(false)
				self._ccbOwner.node_name:setVisible(false)
				self._isDead = true
			end
		end
	end


	return self._isDead
end


function QUIWidgetSocietyDungeonBoss:reBuildActor()
	if self._actorDisplay then
		self._actorDisplay:removeFromParent()
		self._actorDisplay = nil
	end
	if not self._actorDisplay then
		self._actorDisplay = QUIWidgetActorActivityDisplay.new(self._bossId, {})
		self:cleanUp()
		self._ccbOwner.node_boss:addChild(self._actorDisplay)
	end
end

function QUIWidgetSocietyDungeonBoss:playFinishBossDead()
	if self._isPlaying then return end
	self._isPlaying = true
	self._ccbOwner.sp_dead:setVisible(false)
	self._ccbOwner.node_btn_fastFighter:setVisible(false)
	self._ccbOwner.node_hp:setVisible(false)
	self._ccbOwner.node_name:setVisible(false)
	self._avatarHero:stopDisplay()
	self._avatarHero:setAutoStand(false)
	self._avatarHero:displayWithBehavior(ANIMATION_EFFECT.DEAD)
	self._avatarHero:setDisplayBehaviorCallback(function ()
		self._avatarHero:setDisplayBehaviorCallback(nil)
		self._avatarHero:getActor():resetActor()
		self._avatarHero:setOpacity(0)

		self:PlayFlash()
	end)
end

function QUIWidgetSocietyDungeonBoss:PlayFlash()
	
	if self.fcaAnimation == nil then
		self.fcaAnimation = QUIWidgetFcaAnimation.new("fca/wuxianguankai_1", "res")
		self.fcaAnimation:playAnimation("animation", false)
		self.fcaAnimation:setEndCallback(function( )
			self.fcaAnimation:removeFromParent()
			self.fcaAnimation = nil
			self:PlayFlashEnd()
		end)
		self._ccbOwner.node_action:addChild(self.fcaAnimation)
	end
end

function QUIWidgetSocietyDungeonBoss:PlayFlashEnd()

	self._avatarHero:stopDisplay()
	self._avatarHero:setAutoStand(true)
	self._avatarHero:getActor():getSkeletonView():runAction(CCFadeTo:create(0.7,UNION_DUNGEON_MAX_BOSS_OPACITY))
	if self.fcaAnimation == nil then
		self.fcaAnimation = QUIWidgetFcaAnimation.new("fca/wuxianguankai_1", "res")
		self._ccbOwner.node_action:addChild(self.fcaAnimation)
	end


	self.fcaAnimation:playAnimation("animation1", false)
	self.fcaAnimation:setEndCallback(function( )
		self.fcaAnimation:removeFromParent()
		self.fcaAnimation = nil
		self._ccbOwner.node_btn_fastFighter:setVisible(true)
		self._isPlaying = false
		self._isDead = false
		self._ccbOwner.node_hp:setVisible(true)
		self._ccbOwner.node_name:setVisible(true)
		self:setRecommend(true)
	end)

end



function QUIWidgetSocietyDungeonBoss:getTotalHp( bossId, bossLevel )
	if not self._bossId or not self._bossLevel then return 0 end

	if not bossId then bossId = self._bossId end
	if not bossLevel then bossLevel = self._bossLevel end

	local characterData = QStaticDatabase.sharedDatabase():getCharacterDataByID( bossId, bossLevel )
	local totalHp = characterData.hp_value + characterData.hp_grow * characterData.npc_level

	return totalHp
end

function QUIWidgetSocietyDungeonBoss:setAnimationEnd()
	self._isPlaying = false
end

function QUIWidgetSocietyDungeonBoss:isCurTarget()
	return self._isCurTarget
end

function QUIWidgetSocietyDungeonBoss:_onTriggerClick()
	if not self._isCurTarget then
		app.tip:floatTip("哎哟喂～心真大啊，先把我的先锋队解决了再来挑战我吧！")
		return
	end
	if self._isSetting then
		self:dispatchEvent( {name = QUIWidgetSocietyDungeonBoss.EVENT_CLICK, wave = self._wave, chapter = self._chapter} )
		return
	end
	if self._isPlaying or self._isDead then return end
	
	if remote.union:checkUnionDungeonIsOpen(true) == false then
		return
	end
	self:dispatchEvent( {name = QUIWidgetSocietyDungeonBoss.EVENT_CLICK, wave = self._wave, bossHp = self._curHp, chapter = self._chapter} )
end

function QUIWidgetSocietyDungeonBoss:_onTriggerRobot()
	if not self._isCurTarget then
		app.tip:floatTip("哎哟喂～心真大啊，先把我的先锋队解决了再来挑战我吧！")
		return
	end
	if self._isSetting then
		return
	end
	if self._isPlaying or self._isDead then return end
	
	app.sound:playSound("common_small")

	if remote.union:checkUnionDungeonIsOpen(true) == false then
		return
	end
	self:dispatchEvent( {name = QUIWidgetSocietyDungeonBoss.EVENT_ROBOT, wave = self._wave, bossHp = self._curHp, chapter = self._chapter} )
	-- app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRobotForSocietySingle",
	-- 	options = {chapter = self._chapter}})
end

function QUIWidgetSocietyDungeonBoss:_init()
	self:setFocuseNum("")
	self:setRecommend(false)
	self:updateHp()

	local character = QStaticDatabase.sharedDatabase():getCharacterByID(self._bossId)
	self._ccbOwner.tf_name:setString(character.name)
	
	self._ccbOwner.node_hp:setPositionY(self._ccbOwner.node_hp:getPositionY() + (self._scoietyWaveConfig.hp_offset_y or 0))
	self._ccbOwner.tf_focuse:setPositionY(self._ccbOwner.tf_focuse:getPositionY() + (self._scoietyWaveConfig.hp_offset_y or 0))
	self._ccbOwner.sp_recommend:setPositionY(self._ccbOwner.sp_recommend:getPositionY() + (self._scoietyWaveConfig.hp_offset_y or 0))
	
 	if not self._avatarHero then
 		print(" self._bossId = ", self._bossId)
	 	self._avatarHero = QUIWidgetActorDisplay.new(self._bossId)
		self._ccbOwner.node_boss:addChild(self._avatarHero)
	end
	self._ccbOwner.node_boss:setScale(self._bossScale)
	self._ccbOwner.node_action:setScale(self._bossScale)

	self:_showBossType()
	-- self:_showBuff()
end

function QUIWidgetSocietyDungeonBoss:_showBossType()
	if self._isSetting then return end
	-- print("[Kumo] QUIWidgetSocietyDungeonBoss:_showBossType()")
	if self._scoietyWaveConfig and self._scoietyWaveConfig.boss_type then
		local px, py = self._ccbOwner.tf_name:getPosition()
		local tfw = self._ccbOwner.tf_name:getContentSize().width
		local tbl = string.split(self._scoietyWaveConfig.boss_type, ";")
		local count = table.nums(tbl)
		if tbl and count > 0 then
			for index, value in pairs(tbl) do
				local sprite
	 			local spriteFrame = QSpriteFrameByKey("bossType", tonumber(value))
                if spriteFrame then
                	sprite = CCSprite:createWithSpriteFrame(spriteFrame)
                else
                	print("[Kumo] < QUIWidgetSocietyDungeonBoss:_showBossType > value = ", value)
                end
                if sprite then
	                self._ccbOwner.node_name:addChild(sprite)
	                local w = sprite:getContentSize().width
	                -- w = w - 10
	                sprite:setPosition(px - tfw/2 - w*(index-0.5), py)
               	end
			end
		end
	end
end

function QUIWidgetSocietyDungeonBoss:setSoulState()
	if self._avatarHero then
		self._avatarHero:setOpacity(UNION_DUNGEON_MAX_BOSS_OPACITY)
	end
end

-- function QUIWidgetSocietyDungeonBoss:_showBuff()
-- 	if self._isSetting then return end
	
-- 	if self._scoietyWaveConfig and self._scoietyWaveConfig.buff_des_id then
-- 		local buffConfig = QStaticDatabase.sharedDatabase():getScoietyDungeonBuff(self._scoietyWaveConfig.buff_des_id)
-- 		-- local index = self._scoietyWaveConfig.buff_des_id or 0
-- 		local px, py = self._ccbOwner.tf_name:getPosition()
-- 		local tfw = self._ccbOwner.tf_name:getContentSize().width
-- 		local sprite
-- 		local spriteFrame = QSpriteFrameByPath(buffConfig.ICON)
-- 		if spriteFrame then
--         	sprite = CCSprite:createWithSpriteFrame(spriteFrame)
--         else
--         	print("[Kumo] < QUIWidgetSocietyDungeonBoss:_showBossType > value = ", value)
--         end
--         if sprite then
--             self._ccbOwner.node_name:addChild(sprite)
--             local w = sprite:getContentSize().width
--             sprite:setPosition(px + tfw/2 + w, py)
--        	end
-- 	end
-- end

function QUIWidgetSocietyDungeonBoss:_showDead()
	if self._isPlaying then return end
	self._isPlaying = true
	self._ccbOwner.sp_dead:setVisible(false)
	self:reBuildActor()

	self._ccbOwner.node_hp:setVisible(false)
	self._ccbOwner.node_name:setVisible(false)
	self._actorDisplay:stopDisplay()
	self._actorDisplay:setAutoStand(false)
	self._actorDisplay:displayWithBehavior(ANIMATION_EFFECT.DEAD)
	self._actorDisplay:setDisplayBehaviorCallback(function ()
		self._actorDisplay:setDisplayBehaviorCallback(nil)
		-- self._ccbOwner.sp_dead:setVisible(true)
		-- self._ccbOwner.node_boss:setVisible(false)
		-- self._ccbOwner.node_hp:setVisible(false)
		-- self._ccbOwner.node_name:setVisible(false)
		self:dispatchEvent( {name = QUIWidgetSocietyDungeonBoss.EVENT_DEAD, wave = self._wave--[[, bossHp = self._curHp, chapter = self._chapter]]} )
		-- self._isPlaying = false
	end)
end

function QUIWidgetSocietyDungeonBoss:cleanUp()
	if self._avatarHero then
		self._avatarHero:removeFromParent()
		-- self._avatarHero:onCleanup()
		self._avatarHero = nil
	end
end

function QUIWidgetSocietyDungeonBoss:makeColorGray()
	self._ccbOwner.node_btn_fastFighter:setVisible(false)
	if self._avatarHero then
		-- print("[Kumo] QUIWidgetSocietyDungeonBoss:makeColorGray ", self._wave, "false")
		self._isCurTarget = false
		makeNodeFromNormalToGray(self._ccbOwner.node_boss)
		makeNodeFromNormalToGray(self._ccbOwner.node_hp)
		self._ccbOwner.node_hp:setVisible(false)
		self._avatarHero:getActor():getSkeletonView():pauseAnimation()
	end
end

function QUIWidgetSocietyDungeonBoss:makeColorNormal()
	if self._avatarHero then
		-- print("[Kumo] QUIWidgetSocietyDungeonBoss:makeColorNormal ", self._wave, "true")
		self._isCurTarget = true
		makeNodeFromGrayToNormal(self._ccbOwner.node_boss)
		makeNodeFromGrayToNormal(self._ccbOwner.node_hp)
		if self._isFinalBoss or (self._curHp > 0 and not self._isSetting) then
			self._ccbOwner.node_hp:setVisible(true)
			if app.unlock:checkLock("UNLOCK_ZONGMENZIDONGZHANDOU") then
				self._ccbOwner.node_btn_fastFighter:setVisible(true)
			end
		end
		self._avatarHero:getActor():getSkeletonView():resumeAnimation()
	end
end

return QUIWidgetSocietyDungeonBoss