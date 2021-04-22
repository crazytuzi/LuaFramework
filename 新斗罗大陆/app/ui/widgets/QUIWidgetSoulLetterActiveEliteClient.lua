-- @Author: xurui
-- @Date:   2019-05-16 11:22:39
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-10-24 11:19:26
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSoulLetterActiveEliteClient = class("QUIWidgetSoulLetterActiveEliteClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QRichText = import("...utils.QRichText")

QUIWidgetSoulLetterActiveEliteClient.EVENT_CLICK_ACTIVE = "EVENT_CLICK_ACTIVE"
QUIWidgetSoulLetterActiveEliteClient.EVENT_CLICK_BUY = "EVENT_CLICK_BUY"

function QUIWidgetSoulLetterActiveEliteClient:ctor(options)
	local ccbFile = "ccb/Widget_Battle_Pass_Activition.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerBuy", callback = handler(self, self._onTriggerBuy)},
		{ccbCallbackName = "onTriggerActive", callback = handler(self, self._onTriggerActive)},
    }
    QUIWidgetSoulLetterActiveEliteClient.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetSoulLetterActiveEliteClient:onEnter()
end

function QUIWidgetSoulLetterActiveEliteClient:onExit()
end

function QUIWidgetSoulLetterActiveEliteClient:showSuggest()
	self._ccbOwner.node_suggest:setVisible(true)

end

function QUIWidgetSoulLetterActiveEliteClient:setInfo(info, activityProxy)
	self._info = info
	self._activityProxy = activityProxy
	self._activityInfo = self._activityProxy:getActivityInfo()

	self._ccbOwner.tf_title:setString(self._info.name or "")

	self._ccbOwner.node_suggest:setVisible(false)



	local finalAward = self._activityProxy:getFinalAward()
	local award = {}
	remote.items:analysisServerItem(finalAward.rare_reward1, award)
	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(award[1].id)
    local richTextNode = QRichText.new(nil, 220, {stringType = 1, defaultColor = COLORS.a, defaultSize = 18})
	local str = string.gsub(self._info.des or "", "item_name", itemConfig.name or "")
    richTextNode:setString(str)
    richTextNode:setAnchorPoint(0, 1)
    self._ccbOwner.node_tf:addChild(richTextNode)

	self._ccbOwner.tf_num:setString(string.format("%s元", (self._info.price or 0)))

	self:setActiveStatus()

	self._ccbOwner.tf_tip:setVisible(false)
	if self._info.buy_type == 4 and self._activityInfo.type == 4 and self._activityInfo.buyState == 1 then
		local eliteInfo = self._activityProxy:getBuyExpConfigByType(5)[1]
		self._ccbOwner.tf_tip:setVisible(true)
		self._ccbOwner.tf_num:setString(string.format("%s元", (eliteInfo.price or 0)))
	end
end

function QUIWidgetSoulLetterActiveEliteClient:setActiveStatus()
	self._ccbOwner.sp_icon_1:setVisible(self._info.buy_type == 2)
	self._ccbOwner.sp_icon_2:setVisible(self._info.buy_type == 3)
	self._ccbOwner.sp_icon_3:setVisible(self._info.buy_type == 4)

	if self._info.buy_type == 2 then
		self._ccbOwner.node_btn_buy:setVisible(false)
		self._ccbOwner.node_btn_active:setVisible(false)
		self._ccbOwner.sp_done:setVisible(true)
	elseif (self._info.buy_type == 3 and self._activityInfo.type == 2) or (self._info.buy_type == 4 and self._activityInfo.type == 3) then
		self._ccbOwner.node_btn_buy:setVisible(false)
		self._ccbOwner.node_btn_active:setVisible(true)
		self._ccbOwner.sp_done:setVisible(false)
	elseif self._activityInfo.type == 4 and self._info.buy_type == 3 then
		self._ccbOwner.node_btn_buy:setVisible(false)
		self._ccbOwner.node_btn_active:setVisible(false)
		self._ccbOwner.sp_done:setVisible(true)
	else
		self._ccbOwner.node_btn_buy:setVisible(true)
		self._ccbOwner.node_btn_active:setVisible(false)
		self._ccbOwner.sp_done:setVisible(false)
	end
end

function QUIWidgetSoulLetterActiveEliteClient:_onTriggerBuy(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_buy) == false then return end
	local info = self._info
	if self._activityInfo.type == 4 and self._activityInfo.buyState == 1 then
		info = self._activityProxy:getBuyExpConfigByType(5)[1]
	end
	self:dispatchEvent({name = QUIWidgetSoulLetterActiveEliteClient.EVENT_CLICK_BUY, info = info})
end

function QUIWidgetSoulLetterActiveEliteClient:_onTriggerActive(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_active) == false then return end
	self:dispatchEvent({name = QUIWidgetSoulLetterActiveEliteClient.EVENT_CLICK_ACTIVE, info = self._info})
end

function QUIWidgetSoulLetterActiveEliteClient:getContentSize()
	return CCSize(0, 0)
end

return QUIWidgetSoulLetterActiveEliteClient
