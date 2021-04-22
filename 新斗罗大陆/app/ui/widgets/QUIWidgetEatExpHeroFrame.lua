--
-- Author: Your Name
-- Date: 2015-09-18 11:04:27
--
local QUIWidget = import(".QUIWidget")
local QUIWidgetEatExpHeroFrame = class("QUIWidgetEatExpHeroFrame", QUIWidget)

local QUIWidgetHeroHead = import(".QUIWidgetHeroHead")
local QHeroModel = import("...models.QHeroModel")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroProfessionalIcon = import(".QUIWidgetHeroProfessionalIcon")
local QUIViewController = import("..QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QHerosUtils = import("...utils.QHerosUtils")
local QQuickWay = import("...utils.QQuickWay")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QNavigationController = import("...controllers.QNavigationController")

QUIWidgetEatExpHeroFrame.EVENT_HERO_FRAMES_CLICK = "EVENT_HERO_FRAMES_CLICK"

function QUIWidgetEatExpHeroFrame:ctor(options)
	local ccbFile = "ccb/Widget_HeroOverview_sheet.ccbi"
	local callBacks = {{ccbCallbackName = "onTriggerHeroOverview", callback = handler(self, QUIWidgetEatExpHeroFrame._onTriggerHeroOverview)}}
	QUIWidgetEatExpHeroFrame.super.ctor(self,ccbFile,callBacks,options)

	self._mpBar = q.newPercentBarClippingNode(self._ccbOwner.sprite_bar_purple)
    self.stencil = self._mpBar:getStencil()
	self:resetMany()

	if options ~= nil and options.itemId ~= nil then
		self._itemId = options.itemId
	end
	
	self._forceBarScaleX = self._ccbOwner.sprite_bar:getScaleX()
	self._ccbOwner.node_hero_name = setShadow(self._ccbOwner.node_hero_name)

	self._heroHead = QUIWidgetHeroHead.new({})
	self._heroHead:setTouchEnabled(false)
	self._ccbOwner.node_hero_head:addChild(self._heroHead:getView())

	self._talentIcon = QUIWidgetHeroProfessionalIcon.new({})
	self._ccbOwner.node_hero_professional:addChild(self._talentIcon:getView())

	self._eatNum = 0
	self._isGrayDisplay = false
	self._isEating = false
	self._isUp = true
	self._isMax = false
	self._delayTime = 0.2
	self._isMove = false

	
end

function QUIWidgetEatExpHeroFrame:onEnter()
    self._remoteProxy = cc.EventProxy.new(remote)
    self._remoteProxy:addEventListener(remote.HERO_UPDATE_EVENT, handler(self, self.onEvent))

    self._heroProxy = cc.EventProxy.new(remote.herosUtil)
    self._heroProxy:addEventListener(QHerosUtils.EVENT_HERO_LEVEL_UPDATE, handler(self, self.onEvent))
end

function QUIWidgetEatExpHeroFrame:onExit()
	self._heroProxy:removeAllEventListeners()
	self._heroProxy = nil

	self._remoteProxy:removeAllEventListeners()
	self._remoteProxy = nil
	
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
end 

function QUIWidgetEatExpHeroFrame:resetMany()
	self._ccbOwner.node_tips_hero:setVisible(false)
	self._ccbOwner.node_hero_battleForce:setVisible(true)
	self._ccbOwner.soul_icon:setVisible(false)
	self._ccbOwner.node_hero_force_full:setVisible(false)
	self._ccbOwner.node_hero_force:setVisible(false)
	self._ccbOwner.node_hero_equipment:setVisible(false)
	self._ccbOwner.node_hero_fight:setVisible(false)
	self._ccbOwner.sprite_bar:setVisible(false)
	-- self._ccbOwner.sprite_bar_purple:setVisible(true)
	self.stencil:setVisible(true)
	self._ccbOwner.exp_is_full:setVisible(false)
	self._ccbOwner.node_hero_gemstone:setVisible(false)
	self._ccbOwner.node_mount_box:setVisible(false)
	self._ccbOwner.node_artifact_box:setVisible(false)
	self._ccbOwner.node_hero_spar:setVisible(false)
	self._ccbOwner.is_selected:setVisible(false)
	-- self._ccbOwner.sprite_bar_purple:setScaleX(0)
	self.stencil:setScaleX(0)
end

function QUIWidgetEatExpHeroFrame:getName()
	return "QUIWidgetEatExpHeroFrame"
end

function QUIWidgetEatExpHeroFrame:getHero()
	return self._actorId
end

function QUIWidgetEatExpHeroFrame:onEvent(event)
	if event.name == QHerosUtils.EVENT_HERO_LEVEL_UPDATE and event.actorId == self._actorId then
		if self.class ~= nil then
			self:setHero(event.actorId, self._selectTable)
			self:heroUpLevelEffect()
		end
	-- elseif event.name == remote.HERO_UPDATE_EVENT then
	-- 	if self.class ~= nil then
	-- 		self:setHero(self._actorId, self._selectTable)
	-- 	end
	end
end

function QUIWidgetEatExpHeroFrame:setHero(actorId, selectTable)
	self._actorId = actorId
	self._selectTable = selectTable
	self._heroUIModel = remote.herosUtil:getUIHeroByID(self._actorId)
	self._hero = self._heroUIModel._heroInfo

	local database = QStaticDatabase:sharedDatabase()
	local heroInfo = database:getCharacterByID(self._actorId)

	-- 设置头像显示
	self._heroHead:setHeroSkinId(self._hero.skinId)
	self._heroHead:setHero(actorId, level)

	local level = 0
	if self._hero ~= nil then
		level = self._hero.level
		self._ccbOwner.node_hero_name:setColor(BREAKTHROUGH_COLOR_LIGHT["white"])
		--设置进阶
		local breakthroughLevel,color = remote.herosUtil:getBreakThrough(self._hero.breakthrough)
		if color ~= nil then
			self._ccbOwner.node_hero_name:setColor(BREAKTHROUGH_COLOR_LIGHT[color])
		end
		local name = heroInfo.name
		if breakthroughLevel > 0 then
			name = name.." +"..breakthroughLevel
		end
		-- 设置魂师名称
		self._ccbOwner.node_hero_name:setString(name)

		-- 设置魂师天赋	
		self._talentIcon:setHero(self._hero.actorId)
		-- 装备显示

		-- diaplay stars
		self._heroHead:setStar(self._hero.grade)
		self._heroHead:showSabc()
		self._heroHead:setLevel(self._hero.level)

		self._ccbOwner.node_recruitAnimation:setVisible(false)
 		self._maxExp = QStaticDatabase:sharedDatabase():getExperienceByLevel(self._hero.level)
		local scaleX = (self._hero.exp/self._maxExp)
		 -- * 1.58
		-- self._ccbOwner.sprite_bar_purple:setScaleX(scaleX)
		self.stencil:setScaleX(scaleX)
		-- local percent = self._hero.exp/self._maxExp
		-- local totalStencilWidth = self.stencil:getContentSize().width * self.stencil:getScaleX()
		-- self.stencil:setPositionX(-totalStencilWidth + percent*totalStencilWidth)
	end

	local isFind = false
	if self._selectTable ~= nil then
		for _,value in pairs(self._selectTable) do
			if value == actorId then
				isFind = true
				break
			end
		end
	end

	if isFind == true then
		self:selected()
	else
		self:unselected()
	end

	if self._heroUIModel:heroCanUpgrade() == false then
		self:setHeroLevelIsMax()
	else
		self._isMax = false
		self._ccbOwner.node_hero_fight:setVisible(false)
		self._ccbOwner.exp_is_full:setVisible(false)	
	end

	-- self:removeFight()
end

function QUIWidgetEatExpHeroFrame:setHeroLevelIsMax()
	self._isMax = true
	self._ccbOwner.node_hero_fight:setVisible(true)
	-- self._ccbOwner.sprite_bar_purple:setScaleX(1.57)
	self._ccbOwner.exp_is_full:setString("经验已满")
	self._ccbOwner.exp_is_full:setVisible(true)	
	self._heroHead._ccbOwner.head_effect:setVisible(false)

	if self._numEffect ~= nil then
		self._numEffect:disappear()
		self._numEffect = nil
	end
end 

function QUIWidgetEatExpHeroFrame:heroUpLevelEffect()
	if self._heroUplevelEffect == nil then
		self._heroUplevelEffect = QUIWidgetAnimationPlayer.new()
		self._heroHead:addChild(self._heroUplevelEffect)
	end
	self._heroUplevelEffect:playAnimation("ccb/Widget_HeroUpgarde_tis2.ccbi", function(ccbOwner)end, function()
			if self._heroUplevelEffect == nil then
				self._heroUplevelEffect:disappear()
				self._heroUplevelEffect = nil
			end
		end)
end

--刷新当前信息显示
function QUIWidgetEatExpHeroFrame:refreshInfo()
	self:setHero(self._actorId, self._selectTable)
end

function QUIWidgetEatExpHeroFrame:selected()
	self._ccbOwner.node_hero_select:setVisible(true)
end

function QUIWidgetEatExpHeroFrame:unselected()
	self._ccbOwner.node_hero_select:setVisible(false)
end

function QUIWidgetEatExpHeroFrame:setFramePos(pos)
	self._pos = pos
end

function QUIWidgetEatExpHeroFrame:getContentSize()
	return self._ccbOwner.bg:getContentSize()
end

function QUIWidgetEatExpHeroFrame:onExit()
	self._eventProxy = nil
end

--event callback area--
function QUIWidgetEatExpHeroFrame:_onTriggerHeroOverview(tag, menuItem)
	if self._isMax or self._isMove then return end

	if tonumber(tag) == CCControlEventTouchDown then
		self:_onDownHandler()
	else
		self:_onUpHandler()
	end
end

function QUIWidgetEatExpHeroFrame:_onDownHandler()
	self._delayTime = 0.2
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end

	self._isUp = false

	-- 延时一秒 如果一秒内未up或者移动则连续吃经验
	self._timeHandler = scheduler.performWithDelayGlobal(handler(self, self._eatExpItemsForEach), self._delayTime)
end

function QUIWidgetEatExpHeroFrame:_onUpHandler()
	if self._isMove then return end

	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
	if self._isEating == false then
		self:_eatExpItem()
	else
		self._isEating = false
	end

	self:upGrade()
	self._isUp = true
	self._delayTime = 0.1
end

function QUIWidgetEatExpHeroFrame:_eatExpItemsForEach()
	scheduler.unscheduleGlobal(self._timeHandler)
	self._isEating = true
	self._timeHandler = nil
	self._timeHandler = scheduler.performWithDelayGlobal(handler(self, self._eatExpItem), self._delayTime)
end

function QUIWidgetEatExpHeroFrame:_eatExpItem()
	if self._isUp or self._isMove then
		if self._timeHandler ~= nil then
			scheduler.unscheduleGlobal(self._timeHandler)
			self._timeHandler = nil
		end
		return 
	end
	if remote.items:getItemsNumByID(self._itemId) > 0 then
		local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(self._itemId)
		local exp = itemConfig.exp
		if self._heroUIModel:heroCanUpgrade() == true then
			self:addEatNum()
			remote.herosUtil:heroEatExp(itemConfig.exp, self._actorId)
			self:setExpBar()
			self:_showEatNum()
			-- self:_showEffect()
			if self._isEating == true then
				self._delayTime = self._delayTime - 0.01
				self._delayTime = self._delayTime < 0.04 and 0.04 or self._delayTime
				self._timeHandler = scheduler.performWithDelayGlobal(handler(self, self._eatExpItem), self._delayTime)
			end
		else
			self:upGrade()
		end
	else
		self:upGrade()
    	QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self._itemId)
	end
end

function QUIWidgetEatExpHeroFrame:addEatNum()
	if remote.items:removeItemsByID(self._itemId, 1) == false then
		return false
	end
	self._eatNum = self._eatNum + 1
	return true
end

function QUIWidgetEatExpHeroFrame:_showEatNum()
	if self._numEffect == nil then
		self._numEffect = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.node_num_effect:addChild(self._numEffect)
	end
	if self._eatNum <= 1 then
		self._numEffect:playAnimation("ccb/Widget_Upgarde_tips.ccbi", function(ccbOwner)
				ccbOwner.tf_num:setString("×"..self._eatNum)
            end, nil, nil, "Default Timeline")
	else
		self._numEffect:playAnimation("ccb/Widget_Upgarde_tips.ccbi", function(ccbOwner)
				ccbOwner.tf_num:setString("×"..self._eatNum)
            end, nil, nil, "2")
	end
	self._heroHead._ccbOwner.head_effect:setVisible(true)
end

function QUIWidgetEatExpHeroFrame:setExpBar()
	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(self._itemId)
	local exp = itemConfig.exp
	local scaleX = self._hero.exp/self._maxExp 
	-- * 1.57
	-- scaleX = scaleX > 1.57 and 1.57 or scaleX

	-- self._ccbOwner.sprite_bar_purple:runAction(CCScaleTo:create(0.1, scaleX, 1))
	self.stencil:runAction(CCScaleTo:create(0.1,scaleX,1))
end

function QUIWidgetEatExpHeroFrame:upGrade()
	if self._eatNum > 0 then
		app:getClient():intensify(self._actorId, {{itemId = self._itemId, count = self._eatNum}}, function()
			if self.class ~= nil then
				self._eatNum = 0
				self:setHero(self._actorId, self._selectTable)
				self._heroHead._ccbOwner.head_effect:setVisible(false)
			end
		end)
	end
end

function QUIWidgetEatExpHeroFrame:setMoveState(state)
	if state == nil then return end
	self._isMove = state
	self._heroHead._ccbOwner.head_effect:setVisible(false)
	if state == false then
		if self._numEffect ~= nil then
			self._numEffect:disappear()
			self._numEffect = nil
		end
		if self._timeHandler ~= nil then
			scheduler.unscheduleGlobal(self._timeHandler)
			self._timeHandler = nil
		end
	end
end

-- function QUIWidgetEatExpHeroFrame:checkDialogIsMove()
-- 	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
-- 	if dialog ~= nil and dialog.class.__cname == "QUIDialogEatExpHeroOverView" and dialog._isMove then
-- 		return true
-- 	end
-- 	return false
-- end

function QUIWidgetEatExpHeroFrame:_removeDelay()
	if self._delay ~= nil then 
		scheduler.unscheduleGlobal(self._delay)
		self._delay = nil
	end
end

return QUIWidgetEatExpHeroFrame
