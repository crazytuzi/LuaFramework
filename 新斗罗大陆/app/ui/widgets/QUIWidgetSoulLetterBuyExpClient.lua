-- @Author: xurui
-- @Date:   2019-05-15 19:21:29
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-10-24 11:29:30
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSoulLetterBuyExpClient = class("QUIWidgetSoulLetterBuyExpClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

QUIWidgetSoulLetterBuyExpClient.EVENT_CLICK_BUY = "EVENT_CLICK_BUY"
QUIWidgetSoulLetterBuyExpClient.EVENT_CLICK_VIEW = "EVENT_CLICK_VIEW"

function QUIWidgetSoulLetterBuyExpClient:ctor(options)
	local ccbFile = "ccb/Widget_Battle_Pass_Levelup.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerBuy", callback = handler(self, self._onTriggerBuy)},
		{ccbCallbackName = "onTriggerView", callback = handler(self, self._onTriggerView)},
    }
    QUIWidgetSoulLetterBuyExpClient.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetSoulLetterBuyExpClient:onEnter()
end

function QUIWidgetSoulLetterBuyExpClient:onExit()
end

function QUIWidgetSoulLetterBuyExpClient:setShowView()

	self._ccbOwner.node_refresh:setVisible(false)
	self._ccbOwner.node_sale:setVisible(false)
	self._ccbOwner.node_btn_view:setVisible(true)
	local scale_ = self._ccbOwner.node_btn_view:getScale() * 0.908
	self._ccbOwner.node_btn_view:setScale(scale_)
	scale_ = self._ccbOwner.node_name:getScale() * 0.908
	self._ccbOwner.node_name:setScale(scale_)

end

function QUIWidgetSoulLetterBuyExpClient:setInfo(info, activityProxy)
	self._info = info
	self._activityProxy = activityProxy
	self._ccbOwner.node_btn_view:setVisible(false)
	self._ccbOwner.tf_title:setString(self._info.name or "")
	self._ccbOwner.tf_num:setString(self._info.price or "")

	self:setSaleState(self._info.discount or 0)

	local activityInfo = self._activityProxy:getActivityInfo()
	local eliteUnlock = self._activityProxy:checkEliteUnlock()
	local addLevel = math.floor(self._info.exp / 1200)
	local awardNum = 0
	for i = 1, addLevel do
		local expConfig = self._activityProxy:getAwardsConfigByLevel((activityInfo.level or 1) + i)
		if q.isEmpty(expConfig) == false then
			if expConfig.normal_reward then
				awardNum = awardNum + 1
			end
			if eliteUnlock then
				if expConfig.rare_reward1 then
					awardNum = awardNum + 1
				end
				if expConfig.rare_reward2 then
					awardNum = awardNum + 1
				end
			end
		end
	end

	local str = string.split(self._info.des, "#")
	local desc = ""
	for _, value in pairs(str) do
		if value == "number" then
			value = awardNum
		end
		desc = desc..value
	end
	self._ccbOwner.tf_desc:setString(desc)
end

function QUIWidgetSoulLetterBuyExpClient:setSaleState(sale)
	self._ccbOwner.node_sale:setVisible(false)
	self._ccbOwner.chengDisCountBg:setVisible(false)
	self._ccbOwner.lanDisCountBg:setVisible(false)
	self._ccbOwner.ziDisCountBg:setVisible(false)
	self._ccbOwner.hongDisCountBg:setVisible(false)

	self._ccbOwner.sp_icon_1:setVisible(self._info.id == 4)
	self._ccbOwner.sp_icon_2:setVisible(self._info.id == 5)
	self._ccbOwner.sp_icon_3:setVisible(self._info.id == 6)
	self._ccbOwner.sp_icon_4:setVisible(self._info.id == 7)

	if sale == 0 then return end

	if sale < 10 then
		self._ccbOwner.node_sale:setVisible(true)
		if sale < 4 then
			self._ccbOwner.hongDisCountBg:setVisible(true)
		elseif sale < 7 then
			self._ccbOwner.ziDisCountBg:setVisible(true)
		else
			self._ccbOwner.lanDisCountBg:setVisible(true)
		end
		self._ccbOwner.discountStr:setString(string.format("%s折", sale))
	end
end

function QUIWidgetSoulLetterBuyExpClient:_onTriggerBuy(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_buy) == false then return end
	self:dispatchEvent({name = QUIWidgetSoulLetterBuyExpClient.EVENT_CLICK_BUY, info = self._info})
end

function QUIWidgetSoulLetterBuyExpClient:_onTriggerView(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_view) == false then return end
	self:dispatchEvent({name = QUIWidgetSoulLetterBuyExpClient.EVENT_CLICK_VIEW, info = self._info})
end


function QUIWidgetSoulLetterBuyExpClient:getContentSize()
	return CCSize(0, 0)
end

return QUIWidgetSoulLetterBuyExpClient
