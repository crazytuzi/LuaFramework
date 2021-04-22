-- @Author: xurui
-- @Date:   2019-09-18 16:40:01
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-01 16:51:14
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGemstoneHeroQucikExchange = class("QUIWidgetGemstoneHeroQucikExchange", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUIWidgetGemstonesBox = import("..widgets.QUIWidgetGemstonesBox")
local QUIWidgetSparBox = import("..widgets.spar.QUIWidgetSparBox")
local QGemstoneController = import("..controllers.QGemstoneController")

QUIWidgetGemstoneHeroQucikExchange.EVENT_QUICK_EXCHANGE = "EVENT_QUICK_EXCHANGE"
QUIWidgetGemstoneHeroQucikExchange.EVENT_CLICK_HERO_SELECT = "EVENT_CLICK_HERO_SELECT"

function QUIWidgetGemstoneHeroQucikExchange:ctor(options)
	local ccbFile = "ccb/Widget_gemstone_client.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerSelectGemstone", callback = handler(self, self._onTriggerSelectGemstone)},
		{ccbCallbackName = "onTriggerSelectSpar", callback = handler(self, self._onTriggerSelectSpar)},
		{ccbCallbackName = "onTriggerExchange", callback = handler(self, self._onTriggerExchange)},
    }
    QUIWidgetGemstoneHeroQucikExchange.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._gemstoneBoxs = {}
	self._sparBoxs = {}
end

function QUIWidgetGemstoneHeroQucikExchange:onEnter()
end

function QUIWidgetGemstoneHeroQucikExchange:onExit()
end

function QUIWidgetGemstoneHeroQucikExchange:initGLLayer()
	self._glLayerIndex = glLayerIndex or 1

	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_bg, self._glLayerIndex)

	local index = 0
    for i = 1, 4 do
		if self._gemstoneBoxs[i] ~= nil then
			index = self._gemstoneBoxs[i]:initGLLayer(self._glLayerIndex)
		end
	end
	self._glLayerIndex = index
    for i = 1, 2 do
		if self._sparBoxs[i] ~= nil then
			index = self._sparBoxs[i]:initGLLayer(self._glLayerIndex)
		end
	end
	self._glLayerIndex = index

	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp9_gemstone_select, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp9_spar_select, self._glLayerIndex)

	if self._head then
		self._glLayerIndex = self._head:initGLLayer(self._glLayerIndex)
	end

	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_name, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_force_name, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_force, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_select_bg_2, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_no_select_gemstone, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_select_gemstone, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.btn_select_gemstone, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_no_select_spar, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_select_spar, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.btn_select_spar, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_gemstone, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_spar, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.btn_exchange, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_btn_exchange, self._glLayerIndex)
end

function QUIWidgetGemstoneHeroQucikExchange:setInfo(info)
	self._info = info
	self._heroInfo = info.heroInfo 
	self._heroConfig = db:getCharacterByID(self._heroInfo.actorId)

	if not self._head then
		self._head = QUIWidgetHeroHead.new()
		self._ccbOwner.node_head:addChild(self._head)
	end
    self._head:setHeroInfo(self._heroInfo)
	local breakthroughLevel, color = remote.herosUtil:getBreakThrough(self._heroInfo.breakthrough)
	local breakthroughLevelStr = ""
	if breakthroughLevel and breakthroughLevel > 0 then
		breakthroughLevelStr = "+"..tostring(breakthroughLevel)
	end
	self._ccbOwner.tf_name:setString(string.format("LV.%s %s%s", self._heroInfo.level, self._heroConfig.name or "", breakthroughLevelStr))

    local force, unit = q.convertLargerNumber(self._heroInfo.force)
    self._ccbOwner.tf_force:setString(force..(unit or ""))

    for i = 1, 4 do
		if self._gemstoneBoxs[i] == nil then
		    self._gemstoneBoxs[i] = QUIWidgetGemstonesBox.new()
		    self._gemstoneBoxs[i]:setPos(i)
		    self._gemstoneBoxs[i]:setScale(0.8)
		    self._gemstoneBoxs[i]:setPositionY(5)
		    self._ccbOwner["node_gemstone_"..i]:addChild(self._gemstoneBoxs[i])
		end
	end
    for i = 1, 2 do
		if self._sparBoxs[i] == nil then
		    self._sparBoxs[i] = QUIWidgetSparBox.new()
		    self._sparBoxs[i]:setScale(0.8)
		    self._sparBoxs[i]:setNameVisible(false)
		    self._sparBoxs[i]:setPositionY(5)
		    self._ccbOwner["node_spar_"..i]:addChild(self._sparBoxs[i])
		end
	end

    self._gemstoneController = QGemstoneController.new()
    self._gemstoneController:setBoxs(self._gemstoneBoxs, self._sparBoxs)
    self._gemstoneController:setHero(self._heroInfo.actorId)
    self._gemstoneController:hideRedTip()

    self:initGLLayer()

    self:setSelectState()
end

function QUIWidgetGemstoneHeroQucikExchange:setSelectState()
	self._ccbOwner.sp_select_gemstone:setVisible(self._info.selectGemstone)
	self._ccbOwner.sp9_gemstone_select:setVisible(self._info.selectGemstone)

	self._ccbOwner.sp_select_spar:setVisible(self._info.selectSpar)
	self._ccbOwner.sp9_spar_select:setVisible(self._info.selectSpar)
end

function QUIWidgetGemstoneHeroQucikExchange:getContentSize()
	return self._ccbOwner.sp_bg:getContentSize()
end

function QUIWidgetGemstoneHeroQucikExchange:_onTriggerSelectGemstone()
  	app.sound:playSound("common_small")

	self._info.selectGemstone = not self._info.selectGemstone
	self:dispatchEvent({name = QUIWidgetGemstoneHeroQucikExchange.EVENT_CLICK_HERO_SELECT, info = self._info, heroInfo = self._heroInfo, isGemstone = true})
	self:setSelectState()
end

function QUIWidgetGemstoneHeroQucikExchange:_onTriggerSelectSpar()
  	app.sound:playSound("common_small")

	self._info.selectSpar = not self._info.selectSpar
	self:dispatchEvent({name = QUIWidgetGemstoneHeroQucikExchange.EVENT_CLICK_HERO_SELECT, info = self._info, heroInfo = self._heroInfo, isSpar = true})
	self:setSelectState()
end

function QUIWidgetGemstoneHeroQucikExchange:_onTriggerExchange()
	self:dispatchEvent({name = QUIWidgetGemstoneHeroQucikExchange.EVENT_QUICK_EXCHANGE, info = self._info, heroInfo = self._heroInfo})
end

return QUIWidgetGemstoneHeroQucikExchange
