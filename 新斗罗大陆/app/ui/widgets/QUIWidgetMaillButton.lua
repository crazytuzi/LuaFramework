-- @Author: liaoxianbo
-- @Date:   2020-05-21 10:57:15
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-05-27 17:49:42
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMaillButton = class("QUIWidgetMaillButton", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

function QUIWidgetMaillButton:ctor(options)
	local ccbFile = "ccb/Widget_Mail_btncell.ccbi"
    local callBacks = {}
    QUIWidgetMaillButton.super.ctor(self, ccbFile, callBacks, options)
end

function QUIWidgetMaillButton:onEnter()
end

function QUIWidgetMaillButton:onExit()
end

function QUIWidgetMaillButton:setInfo(info,parent)
	self._parentDialog = parent
	self._info = info
	self._ccbOwner.btn_click:setTitleForState(CCString:create(self._info.btnName or ""), CCControlStateNormal)
	self._ccbOwner.btn_click:setTitleForState(CCString:create(self._info.btnName or ""), CCControlStateHighlighted)
	self._ccbOwner.btn_click:setTitleForState(CCString:create(self._info.btnName or ""), CCControlStateDisabled)
	self._ccbOwner.btn_click:setLabelAnchorPoint(ccp(0.55, 0.5))

	self:_checkRedTips()
end

function QUIWidgetMaillButton:_checkRedTips()
	local config = db:getConfiguration()
	self._ccbOwner.node_tips:setVisible(false)
	if self._info.oType == self._parentDialog.ENCHANT_ORIENT_TYPE then
		if remote.user.enchantIsFree or 
			(not app.unlock:getUnlockSeniorRedPoint() and remote.items:getItemsNumByID(config["ENCHANT_BOX_KEY"].value) > 0 and (remote.user.enchantLuckyDrawCount or 0) < 100) then
			self._ccbOwner.node_tips:setVisible(true)
		end		
	end
	if self._info.oType == self._parentDialog.VIP_MALL_TYPE then
		self._ccbOwner.node_tips:setVisible(remote.stores:checkVipShopRedTips())
	end
	
	if self._info.oType == self._parentDialog.MAGICHERB_TYPE then
		if remote.user.magicHerbIsFree or (not app.unlock:getUnlockSeniorRedPoint() and remote.items:getItemsNumByID(MAGIC_HERB_ID) > 0) then
			self._ccbOwner.node_tips:setVisible(true)
		end
	end

	if self._info.oType == self._parentDialog.MOUNT_TYPE then
		if remote.user.mountIsFree or (not app.unlock:getUnlockSeniorRedPoint() and remote.items:getItemsNumByID(162) > 0 and app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.MOUNT_MAILL)) then
			self._ccbOwner.node_tips:setVisible(true)
		end
	end
	if self._info.oType == self._parentDialog.GEMSTONE_TYPE then
		if app.unlock:getUnlockGemStone() and remote.stores:getSaleByShopItemId(SHOP_ID.itemShop, GEMSTONE_SHOP_ID) == 0 then
			self._ccbOwner.node_tips:setVisible(true)
		end
	end

	if self._info.oType == self._parentDialog.ITEM_MALL_TYPE then
		self._ccbOwner.node_tips:setVisible(remote.stores:checkCanRefreshShop2(SHOP_ID.itemShop))
	end

	if self._info.oType == self._parentDialog.SKINSHOP_TYPE then
		self._ccbOwner.node_tips:setVisible(remote.stores:checkSkinShopRedPoint())
	end
end

function QUIWidgetMaillButton:getInfo( )
	return self._info
end

function QUIWidgetMaillButton:setSelect( b)
	self._ccbOwner.btn_click:setHighlighted(b)
	self._ccbOwner.btn_click:setEnabled(not b)

	if b and self._info.oType == self._parentDialog.SKINSHOP_TYPE then
		self._ccbOwner.node_tips:setVisible(false)
		app:getUserOperateRecord():recordeCurrentTime("SKIN_SHOP_READ")
	end
end

function QUIWidgetMaillButton:getContentSize()
	return self._ccbOwner.btn_click:getContentSize()
end

return QUIWidgetMaillButton
