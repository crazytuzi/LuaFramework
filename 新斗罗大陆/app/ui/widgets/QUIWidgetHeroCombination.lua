local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroCombination = class("QUIWidgetHeroCombination", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroCombinationCilent = import("..widgets.QUIWidgetHeroCombinationCilent")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QScrollView = import("...views.QScrollView")
local QUIViewController = import("...ui.QUIViewController")
local QQuickWay = import("...utils.QQuickWay")

function QUIWidgetHeroCombination:ctor(options)
	local ccbFile = "ccb/Widget_HeroSuming.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)}
	}
	QUIWidgetHeroCombination.super.ctor(self, ccbFile, callBacks, options)
	
	cc.GameObject.extend(self)
		self:addComponent("components.behavior.EventProtocol"):exportMethods()
	
	self.combination = {}
	self._isMoving = false

end

function QUIWidgetHeroCombination:onEnter()

	self._itemWidth = self._ccbOwner.sheet_layout:getContentSize().width
	self._itemHeight = self._ccbOwner.sheet_layout:getContentSize().height

    self._scrollView = QScrollView.new(self._ccbOwner.sheet, CCSize(self._itemWidth, self._itemHeight), {bufferMode = 1, sensitiveDistance = 6})

    -- self._scrollView:replaceGradient(self._ccbOwner.node_shadow_top, self._ccbOwner.node_shadow_bottom, nil, nil)
    -- self._scrollView:setGradient(true)
    self._scrollView:setVerticalBounce(true)

	self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewMoving))
	self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onScrollViewBegan))
end

function QUIWidgetHeroCombination:onExit()
end

function QUIWidgetHeroCombination:setHero(actorId)
	if actorId ~= self._actorId then
		for i = 1, #self.combination do
			if self.combination[i] ~= nil then
				self.combination[i]:removeFromParent()
				self.combination[i] = nil
			end
		end
		if self._scrollView then
			self._scrollView:clear()
		end
	end
	self._actorId = actorId 

	self._combinationInfo = QStaticDatabase:sharedDatabase():getCombinationInfoByHeroId(self._actorId)
	if self._combinationInfo == nil then return end
	self._totleHeight = 5

	if self._scrollView then
		self._scrollView:runToTop(false)
	end

	self:setCombination()
end

function QUIWidgetHeroCombination:setCombination()
	local lineDistance = 3
	local _maxWidth = 0
	for i = 1, #self._combinationInfo do
		if self.combination[i] == nil then
			self.combination[i] = QUIWidgetHeroCombinationCilent.new()
			self._scrollView:addItemBox(self.combination[i])
			self.combination[i]:addEventListener(QUIWidgetHeroCombinationCilent.CLICK_HERO_HEAD, handler(self, self._clickHeroHandler))
		end
		self.combination[i]:setCombinationInfo(self._actorId, self._combinationInfo[i])

		local contentSize = self.combination[i]:getContentSize()
		local positionX = contentSize.width/2
		self.combination[i]:setPosition(positionX + 6, -self._totleHeight)

		self._totleHeight = self._totleHeight + contentSize.height+lineDistance
		_maxWidth = math.max(_maxWidth, contentSize.width)
	end
	self._scrollView:setRect(0, -self._totleHeight, 0, _maxWidth)
end

function QUIWidgetHeroCombination:_onScrollViewMoving()
	self._isMoving = true
end

function QUIWidgetHeroCombination:_onScrollViewBegan()
	self._isMoving = false
end

function QUIWidgetHeroCombination:_clickHeroHandler(data)
	if data == nil or self._isMoving then return end

	if data.actorId == nil then
		app.tip:floatTip("该魂师即将开放，敬请期待")
		return 
	end
	app.tip:itemTip(ITEM_TYPE.HERO, data.actorId, true)
end

function QUIWidgetHeroCombination:_onTriggerHelp(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_help) == false then return end
    app.sound:playSound("common_common")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogCombinationRule", 
		options = {actorId = self._actorId}})
end

return QUIWidgetHeroCombination
