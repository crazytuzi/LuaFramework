-- @Author: xurui
-- @Date:   2020-01-17 15:44:18
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-03-16 19:29:08
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroFragmentSecretaryClient = class("QUIWidgetHeroFragmentSecretaryClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

QUIWidgetHeroFragmentSecretaryClient.EVENT_CLICK_SELECT = "EVENT_CLICK_SELECT"
QUIWidgetHeroFragmentSecretaryClient.EVENT_CLICK_SET = "EVENT_CLICK_SET"

function QUIWidgetHeroFragmentSecretaryClient:ctor(options)
	local ccbFile = "ccb/Widget_Secretary_client2.ccbi"
    local callBacks = {
		-- {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetHeroFragmentSecretaryClient.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._selected = false
	self._ccbOwner.node_rank:setVisible(false)
	self._ccbOwner.node_tf_name:setPositionY(-20)
	self._ccbOwner.node_money:setVisible(false) 
	self._ccbOwner.node_btn_set:setVisible(false)
	self._ccbOwner.node_active_tips:setVisible(false)
end

function QUIWidgetHeroFragmentSecretaryClient:onEnter()
end

function QUIWidgetHeroFragmentSecretaryClient:onExit()
end

function QUIWidgetHeroFragmentSecretaryClient:setInfo(info)
	self._info = info or {}
 
	self._ccbOwner.tf_name:setString(info.desc or "")

	if info.settingCallback then
		self._ccbOwner.node_btn_set:setVisible(true)
	end

	--set icon
	if info.icon then
		if self._icon == nil then
			self._icon = CCSprite:create()
			-- self._icon:setScale(0.86)
			self._ccbOwner.node_icon:addChild(self._icon)
		end
		QSetDisplayFrameByPath(self._icon, info.icon)
	end

	self:setAutoAdapterScale()
end

function QUIWidgetHeroFragmentSecretaryClient:setAutoAdapterScale()
	if self._icon then

		local maskSize = self._ccbOwner.ly_mask:getContentSize()
		local iconSize = self._icon:getContentSize()

		local scale = maskSize.width / iconSize.width
		self._ccbOwner.node_icon:setScale(scale)
	end
end

function QUIWidgetHeroFragmentSecretaryClient:setSettingStr(str)
	if str == nil then return end
	self._ccbOwner.tf_set_desc:setString(str)
end

function QUIWidgetHeroFragmentSecretaryClient:setSelectState(state)
	if state == nil then state = false end

	self._selected = state
	self._ccbOwner.sp_select:setVisible(state)
end

function QUIWidgetHeroFragmentSecretaryClient:_onTriggerSelect()
	self:setSelectState(not self._selected)
	self:dispatchEvent({name = QUIWidgetHeroFragmentSecretaryClient.EVENT_CLICK_SELECT, info = self._info, selected = self._selected})
end

function QUIWidgetHeroFragmentSecretaryClient:_onTriggerSet()
	self:dispatchEvent({name = QUIWidgetHeroFragmentSecretaryClient.EVENT_CLICK_SET, info = self._info})
end

function QUIWidgetHeroFragmentSecretaryClient:getContentSize()
	return self._ccbOwner.sp_bg:getContentSize()
end

return QUIWidgetHeroFragmentSecretaryClient
