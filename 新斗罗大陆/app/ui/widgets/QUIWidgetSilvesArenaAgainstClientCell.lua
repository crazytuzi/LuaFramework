--
-- Kumo.Wang
-- 西尔维斯大斗魂场战斗期准备战斗界面Cell
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilvesArenaAgainstClientCell = class("QUIWidgetSilvesArenaAgainstClientCell", QUIWidget)

local QUIWidgetActorDisplay = import(".QUIWidgetActorDisplay")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIWidgetSilvesArenaAgainstClientCell:ctor(options)
	local ccbFile = "ccb/Widget_SilvesArena_Against_Cell.ccbi"
  	local callBacks = {
  		-- {ccbCallbackName = "onTriggerDragPlayer", callback = handler(self, self._onTriggerDragPlayer)},
  	}
	QUIWidgetSilvesArenaAgainstClientCell.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

  	if options then
  		self._info = options.info
  		self._index = options.index
  		self._isUser = options.isUser
  	end

  	self._isShowEnemy = false -- 是否显示影响英雄
  	self._isPlaying = false

	self:_init()
end

function QUIWidgetSilvesArenaAgainstClientCell:onEnter()
	QUIWidgetSilvesArenaAgainstClientCell.super.onEnter(self)
end

function QUIWidgetSilvesArenaAgainstClientCell:onExit()
	QUIWidgetSilvesArenaAgainstClientCell.super.onExit(self)
end

function QUIWidgetSilvesArenaAgainstClientCell:getAvatar()
	return self._avatar
end

function QUIWidgetSilvesArenaAgainstClientCell:isPlaying()
	return self._isPlaying
end

function QUIWidgetSilvesArenaAgainstClientCell:setPlaying( boo )
	self._isPlaying = boo
end

function QUIWidgetSilvesArenaAgainstClientCell:getInfo()
	return self._info
end

function QUIWidgetSilvesArenaAgainstClientCell:showEnemy()
	if not self._isShowEnemy and not self._isUser and self._index == remote.silvesArena.MAX_TEAM_MEMBER_COUNT then
		local effect = QUIWidgetAnimationPlayer.new()
		effect:playAnimation("effects/ChooseHero.ccbi", nil, function()
			effect = nil
			if self._ccbView then
				self._isShowEnemy = true
				self._ccbOwner.node_normal:setVisible(true)
				self._ccbOwner.node_sketch:setVisible(false)
			end
		end)
		self._ccbOwner.node_sketch:addChild(effect)
	end
end

function QUIWidgetSilvesArenaAgainstClientCell:hideInfo()
	if self._ccbView then
		self._ccbOwner.tf_name:setVisible(false)
		self._ccbOwner.tf_force_title:setVisible(false)
		self._ccbOwner.tf_force:setVisible(false)
	end
end

function QUIWidgetSilvesArenaAgainstClientCell:_reset()
	self._ccbOwner.node_avatar:removeAllChildren()
	self._ccbOwner.tf_name:setVisible(false)
	self._ccbOwner.tf_force:setVisible(false)
	self._ccbOwner.tf_force_title:setVisible(false)
end

function QUIWidgetSilvesArenaAgainstClientCell:_init()
	self:_reset()

	self._initAvatarPosX = self._ccbOwner.node_avatar:getPositionX()
	self._initAvatarPosY = self._ccbOwner.node_avatar:getPositionY()

	self._initAvatarScaleX = self._ccbOwner.node_avatar:getScaleX()
	self._initAvatarScaleY = self._ccbOwner.node_avatar:getScaleY()

	if not q.isEmpty(remote.silvesArena.fightInfo) --[[and not q.isEmpty(remote.silvesArena.fightInfo.endInfo)]] then
		-- 说明战斗已经打起来了，在初始化的时候，出现这样的数据，可以判断是战斗过程中短线重连，这时不要隐藏对手信息了
		self._isShowEnemy = true
	end

	if not self._isShowEnemy and not self._isUser and self._index == remote.silvesArena.MAX_TEAM_MEMBER_COUNT then
		self._ccbOwner.node_normal:setVisible(false)
		self._ccbOwner.node_sketch:setVisible(true)
	else
		self._ccbOwner.node_normal:setVisible(true)
		self._ccbOwner.node_sketch:setVisible(false)
	end

	if not q.isEmpty(self._info) then
		self._avatar = QUIWidgetActorDisplay.new( self._info.defaultActorId, {heroInfo = {skinId = self._info.defaultSkinId}} )
		if self._isUser then
			self._avatar:setScaleX(-0.7)
			self._avatar:setScaleY(0.7)
		else
			self._avatar:setScale(0.7)
		end
		self._ccbOwner.node_avatar:addChild(self._avatar)

		if self._info.name then
			self._ccbOwner.tf_name:setString(self._info.name)
			self._ccbOwner.tf_name:setVisible(true)
		end

		if self._info.force then
			local num, unit = q.convertLargerNumber(self._info.force)
			self._ccbOwner.tf_force:setString(num..(unit or ""))
			self._ccbOwner.tf_force:setVisible(true)
			self._ccbOwner.tf_force_title:setVisible(true)
		end
	end
end

function QUIWidgetSilvesArenaAgainstClientCell:isTouchIn(pos)
	if not self._pos or not self._size then
		self._pos = ccp(self._ccbOwner.node_size:getPosition())
		self._size = self._ccbOwner.node_size:getContentSize()
		self._minPosX = self._pos.x - self._size.width/2
		self._maxPosX = self._pos.x + self._size.width/2
		self._minPosY = self._pos.y
		self._maxPosY = self._pos.y + self._size.height
	end
	-- print("x : ", self._minPosX, self._maxPosX, pos.x)
	-- print("y : ", self._minPosY, self._maxPosY, pos.y)
	if pos.x >= self._minPosX and pos.x <= self._maxPosX and pos.y >= self._minPosY and pos.y <= self._maxPosY then
		return true
	end
	return false
end

function QUIWidgetSilvesArenaAgainstClientCell:setOffsetScale(scale)
	self._ccbOwner.node_avatar:setScaleX(self._initAvatarScaleX + scale.x)
	self._ccbOwner.node_avatar:setScaleY(self._initAvatarScaleY + scale.y)
end

function QUIWidgetSilvesArenaAgainstClientCell:setOffsetPos(pos)
	self._ccbOwner.node_avatar:setPositionX(self._initAvatarPosX + pos.x)
	self._ccbOwner.node_avatar:setPositionY(self._initAvatarPosY + pos.y)
end

return QUIWidgetSilvesArenaAgainstClientCell