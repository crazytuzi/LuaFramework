local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetBlackRockBattlePlayer = class("QUIWidgetBlackRockBattlePlayer", QUIWidget)
local QUIWidgetActorDisplay = import("...widgets.actorDisplay.QUIWidgetActorDisplay")
local QStaticDatabase = import("....controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("...widgets.QUIWidgetAnimationPlayer")

function QUIWidgetBlackRockBattlePlayer:ctor(options)
	local ccbFile = "ccb/Widget_Black_mountain_zdren.ccbi"
	local callBacks = {
        -- {ccbCallbackName = "onTriggerClickCard", callback = handler(self, self._onTriggerClickCard)},
    }
	QUIWidgetBlackRockBattlePlayer.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetBlackRockBattlePlayer:setPlayerInfo(playerInfo, progress)
	self._playerInfo = playerInfo
	self._progress = progress
	if self._avatar ~= nil then
		self._avatar:removeFromParent()
		self._avatar = nil
	end
	
	self._avatar = QUIWidgetActorDisplay.new(self._playerInfo.defaultActorId, {heroInfo = {skinId = self._playerInfo.defaultSkinId}})
	self._avatar:setScaleX(-1)
	self._ccbOwner.node_avatar:addChild(self._avatar)

	local name = self._playerInfo.name
	if self._playerInfo.isNpc == true then
		name = "【佣兵】"..name
	end
	self._ccbOwner.tf_name:setString(name)
	if self._playerInfo.userId == remote.user.userId then
		self._ccbOwner.tf_name:setColor(UNITY_COLOR_LIGHT.yellow)
	else
		self._ccbOwner.tf_name:setColor(UNITY_COLOR_LIGHT.white)
	end

	local hp = 0
	local maxHp = 0
	local heroHps = {}
	for _,heroInfo in ipairs(self._progress.herosHpMp or {}) do
		heroHps[heroInfo.actorId] = heroInfo
	end
	for _,heroInfo in ipairs(self._progress.topnHerosHp) do
		if heroHps[heroInfo.actorId] ~= nil then
			hp = hp + heroHps[heroInfo.actorId].currHp
		else
			hp = hp + heroInfo.maxHp
		end
		maxHp = maxHp + heroInfo.maxHp
	end
	self._ccbOwner.sp_hp:setScaleX(0.8 * math.min(1, hp/maxHp))
end

function QUIWidgetBlackRockBattlePlayer:setBuff(isAnimation)
	local buffId = remote.blackrock:getBuff()
	if buffId == nil then return end
	
	if self._buff == nil then
		self._buff = QUIWidget.new("ccb/effects/Widget_Black_mounatin_tubiao.ccbi")
		local parent = self._ccbOwner.tf_name:getParent()
		parent:addChild(self._buff)
	end
	local pos = ccp(self._ccbOwner.tf_name:getPosition())
	pos.x = pos.x - self._ccbOwner.tf_name:getContentSize().width/2
	self._buff:setPositionX(pos.x - 20)
	self._buff:setPositionY(10)
	self._buff:setScale(0.4)

	self._buff._ccbOwner.node_hp:setVisible(false)
	self._buff._ccbOwner.node_attack:setVisible(false)
	self._buff._ccbOwner.node_armor:setVisible(false)
	self._buff._ccbOwner.node_energy:setVisible(false)

	local config = QStaticDatabase:sharedDatabase():getBlackRockBuffId(buffId)
	if config.type == "hp" then
		self._buff._ccbOwner.node_hp:setVisible(true)
	elseif config.type == "attack" then
		self._buff._ccbOwner.node_attack:setVisible(true)
	elseif config.type == "armor" then
		self._buff._ccbOwner.node_armor:setVisible(true)
	elseif config.type == "energy" then
		self._buff._ccbOwner.node_energy:setVisible(true)
	end

	-- if isAnimation == true then
	-- 	local effectPlayer = QUIWidgetAnimationPlayer.new()
	-- 	self:addChild(effectPlayer)
	-- 	effectPlayer:playAnimation("ccb/effects/Widget_Black_mounatin_buff2.ccbi",function (ccbOwner)
	-- 		ccbOwner.node_hp:setVisible(false)
	-- 		ccbOwner.node_energy:setVisible(false)
	-- 		ccbOwner.node_armor:setVisible(false)
	-- 		ccbOwner.node_attack:setVisible(false)
	-- 		if config.type == "hp" then
	-- 			ccbOwner.node_hp:setVisible(true)
	-- 		elseif config.type == "attack" then
	-- 			ccbOwner.node_attack:setVisible(true)
	-- 		elseif config.type == "armor" then
	-- 			ccbOwner.node_armor:setVisible(true)
	-- 		elseif config.type == "energy" then
	-- 			ccbOwner.node_energy:setVisible(true)
	-- 		end
	-- 	end,function ()
	-- 		effectPlayer:disappear()
	-- 	end)

	-- 	self._buff:setScale(0)
	-- 	local inArray = CCArray:create()
	-- 	inArray:addObject(CCScaleTo:create(0.1, 0.5, 0.5))
	-- 	inArray:addObject(CCScaleTo:create(1/30, 0.4, 0.4))
	-- 	self._buff:runAction(CCSequence:create(inArray))
	-- end
end

function QUIWidgetBlackRockBattlePlayer:setGridPos(pos)
	self._gridPos = pos
end

function QUIWidgetBlackRockBattlePlayer:getGridPos()
	return self._gridPos
end

function QUIWidgetBlackRockBattlePlayer:setNextPos(pos)
	self._gridNextPos = pos
end

function QUIWidgetBlackRockBattlePlayer:getNextPos()
	return self._gridNextPos
end

--播放动作
function QUIWidgetBlackRockBattlePlayer:avatarPlayAnimation(value, callback)
	if self._avatar ~= nil then
		self._avatar:displayWithBehavior(value)
		self._avatar:setDisplayBehaviorCallback(callback)
	end
end

--设置HP是否可见
function QUIWidgetBlackRockBattlePlayer:setHp(b)
	self._ccbOwner.node_hp:setVisible(b)
end

function QUIWidgetBlackRockBattlePlayer:getAvatar()
	return self._avatar
end

function QUIWidgetBlackRockBattlePlayer:setAutoStand(b)
	if self._avatar ~= nil then
		self._avatar:setAutoStand(b)
	end
end

function QUIWidgetBlackRockBattlePlayer:pauseAnimation()
	self._avatar:getActor():getSkeletonView():pauseAnimation()
end

function QUIWidgetBlackRockBattlePlayer:setGray()
	makeNodeFromNormalToGray(self._avatar)
end

function QUIWidgetBlackRockBattlePlayer:resumeAnimation()
	self._avatar:getActor():getSkeletonView():resumeAnimation()
end

return QUIWidgetBlackRockBattlePlayer