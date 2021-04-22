--
-- Kumo.Wang
-- 西尔维斯大斗魂场战斗期准备战斗界面Cell
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilvesArenaPeakAgainstClientCell = class("QUIWidgetSilvesArenaPeakAgainstClientCell", QUIWidget)

local QUIWidgetActorDisplay = import(".QUIWidgetActorDisplay")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIWidgetSilvesArenaPeakAgainstClientCell:ctor(options)
	local ccbFile = "ccb/Widget_SilvesArena_Peak_Against_Cell.ccbi"
  	local callBacks = {
  		-- {ccbCallbackName = "onTriggerDragPlayer", callback = handler(self, self._onTriggerDragPlayer)},
  	}
	QUIWidgetSilvesArenaPeakAgainstClientCell.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

  	if options then
  		self._info = options.info
  		self._index = options.index
  		self._isNotHide = options.isNotHide
  		self._isLeft = options.isLeft
  	end

  	self._isShowEnemy = false -- 是否显示影响英雄
  	self._isPlaying = false

	self:_init()
end

function QUIWidgetSilvesArenaPeakAgainstClientCell:onEnter()
	QUIWidgetSilvesArenaPeakAgainstClientCell.super.onEnter(self)
end

function QUIWidgetSilvesArenaPeakAgainstClientCell:onExit()
	QUIWidgetSilvesArenaPeakAgainstClientCell.super.onExit(self)
end

function QUIWidgetSilvesArenaPeakAgainstClientCell:getAvatar()
	return self._avatar
end

function QUIWidgetSilvesArenaPeakAgainstClientCell:isPlaying()
	return self._isPlaying
end

function QUIWidgetSilvesArenaPeakAgainstClientCell:setPlaying( boo )
	self._isPlaying = boo
end

function QUIWidgetSilvesArenaPeakAgainstClientCell:getInfo()
	return self._info
end

function QUIWidgetSilvesArenaPeakAgainstClientCell:showEnemy()
	if not self._isShowEnemy and not self._isNotHide and self._index == remote.silvesArena.MAX_TEAM_MEMBER_COUNT then
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

function QUIWidgetSilvesArenaPeakAgainstClientCell:hideInfo()
	if self._ccbView then
		self._ccbOwner.tf_name:setVisible(false)
		self._ccbOwner.tf_force_title:setVisible(false)
		self._ccbOwner.tf_force:setVisible(false)
	end
end

function QUIWidgetSilvesArenaPeakAgainstClientCell:_reset()
	self._ccbOwner.node_avatar:removeAllChildren()
	self._ccbOwner.tf_name:setVisible(false)
	self._ccbOwner.tf_force:setVisible(false)
	self._ccbOwner.tf_force_title:setVisible(false)
end

function QUIWidgetSilvesArenaPeakAgainstClientCell:_init()
	self:_reset()

	self._initAvatarPosX = self._ccbOwner.node_avatar:getPositionX()
	self._initAvatarPosY = self._ccbOwner.node_avatar:getPositionY()

	self._initAvatarScaleX = self._ccbOwner.node_avatar:getScaleX()
	self._initAvatarScaleY = self._ccbOwner.node_avatar:getScaleY()

	if not q.isEmpty(remote.silvesArena.fightInfo) --[[and not q.isEmpty(remote.silvesArena.fightInfo.endInfo)]] then
		-- 说明战斗已经打起来了，在初始化的时候，出现这样的数据，可以判断是战斗过程中短线重连，这时不要隐藏对手信息了
		self._isShowEnemy = true
	end

	local hideIndeList = remote.silvesArena:getHideMemberIndexList()
	local isHideIndex = false
	for _, index in ipairs(hideIndeList) do
		if index == self._index then
			isHideIndex = true
			break
		end
	end
	if not self._isShowEnemy and not self._isNotHide and isHideIndex then
		self._ccbOwner.node_normal:setVisible(false)
		self._ccbOwner.node_sketch:setVisible(true)
	else
		self._ccbOwner.node_normal:setVisible(true)
		self._ccbOwner.node_sketch:setVisible(false)
	end

	if not q.isEmpty(self._info) then
		self._avatar = QUIWidgetActorDisplay.new( self._info.defaultActorId, {heroInfo = {skinId = self._info.defaultSkinId}} )
		if self._isLeft then
			self._avatar:setScaleX(-0.7)
			self._avatar:setScaleY(0.7)
			self._ccbOwner.node_sketch:setScaleX(-1)
		else
			self._avatar:setScale(0.7)
			self._ccbOwner.node_sketch:setScaleX(1)
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

	if self._isLeft then
		QSetDisplayFrameByPath(self._ccbOwner.sp_number, QResPath("silves_arena_number_left")[self._index])
		QSetDisplayFrameByPath(self._ccbOwner.sp_bg, QResPath("silves_arena_number_left_bg"))
	else
		QSetDisplayFrameByPath(self._ccbOwner.sp_number, QResPath("silves_arena_number_right")[self._index])
		QSetDisplayFrameByPath(self._ccbOwner.sp_bg, QResPath("silves_arena_number_right_bg"))
	end
end

function QUIWidgetSilvesArenaPeakAgainstClientCell:isTouchIn(pos)
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

function QUIWidgetSilvesArenaPeakAgainstClientCell:setOffsetScale(scale)
	self._ccbOwner.node_avatar:setScaleX(self._initAvatarScaleX + scale.x)
	self._ccbOwner.node_avatar:setScaleY(self._initAvatarScaleY + scale.y)
end

function QUIWidgetSilvesArenaPeakAgainstClientCell:setOffsetPos(pos)
	self._ccbOwner.node_avatar:setPositionX(self._initAvatarPosX + pos.x)
	self._ccbOwner.node_avatar:setPositionY(self._initAvatarPosY + pos.y)
end

return QUIWidgetSilvesArenaPeakAgainstClientCell