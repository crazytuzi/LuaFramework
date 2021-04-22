--
-- zxs
-- 战斗结束数据
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetFightEndData = class("QUIWidgetFightEndData", QUIWidget)
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUIWidgetHeroProfessionalIcon = import("..widgets.QUIWidgetHeroProfessionalIcon")
local QUIWidgetAgainstRecordProgressBar = import("..widgets.QUIWidgetAgainstRecordProgressBar")

function QUIWidgetFightEndData:ctor(options)
	local ccbFile = "ccb/Widget_FightEnd_data.ccbi"
	local callBack = {
	}
	QUIWidgetFightEndData.super.ctor(self, ccbFile, callBack, options)

	self._height = self._ccbOwner.node_size:getContentSize().height
	self._originalScale = self._ccbOwner.sp_sprite_red:getScaleX()
end

function QUIWidgetFightEndData:initGLLayer(glLayerIndex)
	self._glLayerIndex = glLayerIndex or 1
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sprite_back, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_sprite_green, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_sprite_red, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_hurt, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_line_1, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_line_2, self._glLayerIndex)
	if self._iconWidget then
		self._glLayerIndex = self._iconWidget:initGLLayer(self._glLayerIndex)
	end
	if self._headWidget then
		self._glLayerIndex = self._headWidget:initGLLayer(self._glLayerIndex)
	end
	return self._glLayerIndex
end

function QUIWidgetFightEndData:onEnter()
end

function QUIWidgetFightEndData:onExit()
	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end
end

function QUIWidgetFightEndData:boundingBox( )
	local scalex = self:getScaleX() or 1
	local scaley = self:getScaleY() or 1
	local size = self._ccbOwner.sprite_back:getContentSize()
	return { origin={x = 0, y = 0}, size = {width = size.width * scalex, height = size.height * scaley}}
end

function QUIWidgetFightEndData:getInfo()
	return self._info
end

function QUIWidgetFightEndData:getIsHero()
	return self._isHero
end

function QUIWidgetFightEndData:setInfo(info, isHero, maxValue)
	self._ccbOwner.node_talent_right:removeAllChildren()
	self._ccbOwner.node_talent_left:removeAllChildren()
	self._ccbOwner.node_head_right:removeAllChildren()
	self._ccbOwner.node_head_left:removeAllChildren()
	self._ccbOwner.sp_sprite_red:setVisible(false)
	self._ccbOwner.sp_sprite_green:setVisible(false)

	self._info = info
	self._isHero = isHero

	local nodeIcon
	local nodeHead
	if self._isHero then
		nodeIcon = self._ccbOwner.node_talent_left
		nodeHead = self._ccbOwner.node_head_left		
	else
		nodeIcon = self._ccbOwner.node_talent_right
		nodeHead = self._ccbOwner.node_head_right
	end

	self._iconWidget = QUIWidgetHeroProfessionalIcon.new()
	self._iconWidget:setHero(info.actorId)
	nodeIcon:addChild(self._iconWidget)

	local level = 0
	if info.heroInfo and info.heroInfo.level then
		level = info.heroInfo.level
	else
		local obj = remote.herosUtil:getHeroByID(info.actorId)
		if obj then
			level = obj.level
		end
	end
	self._headWidget = QUIWidgetHeroHead.new()
	nodeHead:addChild(self._headWidget)
	self._headWidget:setHeroSkinId(info.heroInfo.skinId)
	self._headWidget:setHero(info.actorId, level)
	self._headWidget:setStar(info.heroInfo.grade or 0)
	self._headWidget:showSabc()
	if info.isSoulSpirit then
		self._headWidget:setTeam(1)
		self._headWidget:setSoulSpiritFrame()
	else
		self._headWidget:setTeam(info.isSupport and 2 or 1)
		self._headWidget:setBreakthrough(info.heroInfo.breakthrough or 0)
		self._headWidget:setGodSkillShowLevel(info.heroInfo.godSkillGrade or 0)
	end

	local value = 0
	local str = ""
	local progress = 0
	if info.isTreat then
		value =	info.treat or 0
		str = "治疗 "
	else
		value = info.damage or 0
		str = "伤害 "
	end
	if value > 0 then
	 	progress = math.max(value/maxValue, 0.005)
	end
	self:setValue(0, value, 0, progress, str)
end

function QUIWidgetFightEndData:setValue(startValue, endValue, startProgress, endProgress, prefix)
	local label = self._ccbOwner.tf_hurt
	label:setString("")

	local bar
	local coefficient
	if self._isHero then
		bar = self._ccbOwner.sp_sprite_green
		coefficient = 1
	else
		bar = self._ccbOwner.sp_sprite_red
		coefficient = -1
	end
	bar:setVisible(true)

	local hpBarClippingNode = q.newPercentBarClippingNode(bar)
    local stencil = hpBarClippingNode:getStencil()
    local totalStencilWidth = stencil:getContentSize().width * stencil:getScaleX()
    stencil:setPositionX((-totalStencilWidth + 0*totalStencilWidth) * coefficient )

	local startScale = self._originalScale * startProgress
	local endScale = self._originalScale * endProgress
	local procedureTime = 0.5
	local startTime
	self._scheduler = scheduler.scheduleGlobal(function()
		if not startTime then
			startTime = q.time()
		end
		local current = (q.time() - startTime) / procedureTime
		current = math.min(current, 1.0)

		local currentValue = math.sampler(startValue, endValue, current)
		local currentScale = math.sampler(startScale, endScale, current)
		local force, unit = q.convertLargerNumber(math.floor(currentValue))
		label:setString(prefix..force..unit)
		stencil:setPositionX((-totalStencilWidth + currentScale/self._originalScale*totalStencilWidth) * coefficient)
		
		if current == 1.0 then
			scheduler.unscheduleGlobal(self._scheduler)
			self._scheduler = nil
		end
	end, 0)
end

return QUIWidgetFightEndData

