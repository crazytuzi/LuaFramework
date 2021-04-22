--
-- Author: Your Name
-- Date: 2015-12-18 20:17:11
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetShopBar = class("QUIWidgetShopBar", QUIWidget)

local QVIPUtil = import("...utils.QVIPUtil")

QUIWidgetShopBar.EVENT_CLICK_SHOP_BAR = "EVENT_CLICK_SHOP_BAR"

function QUIWidgetShopBar:ctor(options)
	local ccbFile = "ccb/Widget_FliyBoat_Shop.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClickShop", callback = handler(self, self._onTriggerClickShop)},
	}
	QUIWidgetShopBar.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

	if options then
		self._shopType = options.shopType
	end

	self:resetAll()
	self._isLock = false

	self:setShopBarInfo()
	self:checkShopUnlock()
end

function QUIWidgetShopBar:onEnter()
end

function QUIWidgetShopBar:onExit()
	if self._scheduler ~= nil then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end
end

function QUIWidgetShopBar:getContentsize()
	-- body
	return CCSize(320, 500)
	-- return self._ccbOwner.shop_is_lock:getContentSize()
end

function QUIWidgetShopBar:resetAll()
	self._ccbOwner.soul_icon:setVisible(false)
	self._ccbOwner.normal_icon:setVisible(false)
	self._ccbOwner.black_icon:setVisible(false)
	self._ccbOwner.soul_title:setVisible(false)
	self._ccbOwner.normal_title:setVisible(false)
	self._ccbOwner.black_title:setVisible(false)
	self._ccbOwner.node_tips:setVisible(false)
	self._ccbOwner.red_tips:setVisible(false)
	-- self._ccbOwner.shop_is_lock:setVisible(false)
	makeNodeFromGrayToNormal(self._ccbOwner.node_box)
	self._ccbOwner.thunder_title:setVisible(false)
	self._ccbOwner.sunwar_title:setVisible(false)
end

function QUIWidgetShopBar:setShopBarInfo()
	local word = ""
	if self._shopType == SHOP_ID.soulShop then
		self._ccbOwner.soul_icon:setVisible(true)
		self._ccbOwner.soul_title:setVisible(true)
		word = "刷取高级魂师碎片\n、各种珍贵资源"
	elseif self._shopType == SHOP_ID.generalShop then
		self._ccbOwner.normal_icon:setVisible(true)
		self._ccbOwner.normal_title:setVisible(true)
		word = "低价购买装备材料\n、魂师碎片等"
	elseif self._shopType == SHOP_ID.blackShop then
		self._ccbOwner.black_icon:setVisible(true)
		self._ccbOwner.black_title:setVisible(true)
		word = "获得高级魂师碎片\n、各种资源"
	elseif self._shopType == SHOP_ID.thunderShop then
		self._ccbOwner.black_icon:setVisible(true)
		self._ccbOwner.thunder_title:setVisible(true)
		-- 雷电王座商店
		word = "出售戒指养成材料\n、高级魂师碎片"
	elseif self._shopType == SHOP_ID.sunwellShop then
		self._ccbOwner.black_icon:setVisible(true)
		self._ccbOwner.sunwar_title:setVisible(true)
		-- 战场商店
		word = "出售金魂币、高级\n魂师碎片"
	end
	self._ccbOwner.shop_dec:setString(word)
end

function QUIWidgetShopBar:checkShopUnlock()
	local word = ""
	if self._shopType == SHOP_ID.soulShop then
		if app.unlock:getUnlockHeroStore() == false then
			self._ccbOwner.node_tips:setVisible(true)
			word = "战队"..app.unlock:getConfigByKey("UNLOCK_SOUL_SHOP").team_level.."级开启"
			makeNodeFromNormalToGray(self._ccbOwner.node_box)
			-- self._ccbOwner.shop_is_lock:setVisible(true)
			self._isLock = true
		end
	elseif self._shopType == SHOP_ID.generalShop then
		if app.unlock:getUnlockShop() == false then
			self._ccbOwner.node_tips:setVisible(true)
			word = "战队"..app.unlock:getConfigByKey("UNLOCK_SHOP").team_level.."级开启"
			makeNodeFromNormalToGray(self._ccbOwner.node_box)
			-- self._ccbOwner.shop_is_lock:setVisible(true)
			self._isLock = true
		end
	elseif self._shopType == SHOP_ID.thunderShop then
	if app.unlock:getUnlockInvasion() == false then
		self._ccbOwner.node_tips:setVisible(true)
		word = "战队"..app.unlock:getConfigByKey("UNLOCK_FORTRESS").team_level.."级开启"
		-- self._ccbOwner.shop_is_lock:setVisible(true)
		makeNodeFromNormalToGray(self._ccbOwner.node_box)
		self._isLock = true
	end
	elseif self._shopType == SHOP_ID.sunwellShop then
	if app.unlock:getUnlockSunWar() == false then
		self._ccbOwner.node_tips:setVisible(true)
		word = "战队"..app.unlock:getConfigByKey("UNLOCK_SUNWELL").team_level.."级开启"
		-- self._ccbOwner.shop_is_lock:setVisible(true)
		makeNodeFromNormalToGray(self._ccbOwner.node_box)
		self._isLock = true
	end
	elseif self._shopType == SHOP_ID.blackShop then
		if app.unlock:getUnlockShop2() == false then
			self._ccbOwner.node_tips:setVisible(true)
			local unlockInfo = app.unlock:getConfigByKey("UNLOCK_SHOP_2")
			word = "VIP"..unlockInfo.vip_level.."或战队"..unlockInfo.team_level.."级开启"
			-- self._ccbOwner.shop_is_lock:setVisible(true)
			makeNodeFromNormalToGray(self._ccbOwner.node_box)
			self._isLock = true
		else
			if QVIPUtil:enableBlackMarketPermanent() == false and remote.stores:checkMystoryStoreTimeOut(SHOP_ID.blackShop) == false then
				self._ccbOwner.node_tips:setVisible(true)
				word = "攻打副本概率出现"
				self._isLock = true
			end
		end
	end
	self._ccbOwner.shop_condition:setString(word)

	-- if self._isLock then
	-- 	makeNodeFromNormalToGray(self:getView())
	-- else
	-- 	makeNodeFromGrayToNormal(self:getView())
	-- end
end

function QUIWidgetShopBar:setRedTips(state)
	self._ccbOwner.red_tips:setVisible(state)
end

function QUIWidgetShopBar:_onTriggerClickShop(event)
	if self._isLock then return end

	if tonumber(event) == CCControlEventTouchDown then
		self:getView():setScale(1.05)
	elseif tonumber(event) == CCControlEventTouchUpInside then
		self:getView():setScale(1)
		self._scheduler = scheduler.performWithDelayGlobal(function()
				if self.class ~= nil then
					self:dispatchEvent({name = QUIWidgetShopBar.EVENT_CLICK_SHOP_BAR, shopType = self._shopType})
				end
			end, 0)
	else
		self:getView():setScale(1)
	end
end

return QUIWidgetShopBar