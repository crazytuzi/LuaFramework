-- @Author: xurui
-- @Date:   2019-05-14 10:55:18
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-08-22 15:02:13
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivitySoulLetterAwardClient = class("QUIWidgetActivitySoulLetterAwardClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

QUIWidgetActivitySoulLetterAwardClient.EVENT_CLICK_NORAML = "EVENT_CLICK_NORAML"
QUIWidgetActivitySoulLetterAwardClient.EVENT_CLICK_ELITE = "EVENT_CLICK_ELITE"

function QUIWidgetActivitySoulLetterAwardClient:ctor(options)
	local ccbFile = "ccb/Widget_Battle_Pass.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClickNormal", callback = handler(self, self._onTriggerClickNormal)},
		{ccbCallbackName = "onTriggerClickElite", callback = handler(self, self._onTriggerClickElite)},
    }
    QUIWidgetActivitySoulLetterAwardClient.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._normalItem = nil     --普通奖励item
	self._eliteItem = {}       --精英奖励item
end

function QUIWidgetActivitySoulLetterAwardClient:onEnter()
end

function QUIWidgetActivitySoulLetterAwardClient:onExit()
end

function QUIWidgetActivitySoulLetterAwardClient:setInfo(info, activityProxy)
	self._info = info
	self._activityProxy = activityProxy

	self._ccbOwner.tf_title:setString((self._info.level or 0).."级")

	self:setAwards()

	self:setAwardState()

	self:initGLLayer()
end

function QUIWidgetActivitySoulLetterAwardClient:setAwards()
	--normal award
	if self._info.normal_reward then
		if self._normalItem == nil then
			self._normalItem = QUIWidgetItemsBox.new()
			self._ccbOwner.node_normal_item:addChild(self._normalItem)
		end
		local normalAwards = {}
		remote.items:analysisServerItem(self._info.normal_reward, normalAwards)
		self._normalItem:setGoodsInfo(normalAwards[1].id, normalAwards[1].typeName, normalAwards[1].count)

		local normalRecived = self._activityProxy:checkNormalAwardStatus(self._info.level)
		if (not normalRecived) and self._info.is_highlight1 then
			self._normalItem:showBoxEffect("effects/leiji_light.ccbi", true, 0, 0, 0.6)
		else
			self._normalItem:removeEffect()
		end
	else
		if self._normalItem then
			self._normalItem:removeFromParent()
			self._normalItem = nil
		end
	end

	--elite award
	local eliteRecived = self._activityProxy:checkEliteAwardStatus(self._info.level)
	for i = 1, 2 do
		if self._info["rare_reward"..i] then
			if self._eliteItem[i] == nil then
				self._eliteItem[i] = QUIWidgetItemsBox.new()
				self._ccbOwner["node_elite_item"..i]:addChild(self._eliteItem[i])
			end
			local eliteAwards = {}
			remote.items:analysisServerItem(self._info["rare_reward"..i], eliteAwards)
			self._eliteItem[i]:setGoodsInfo(eliteAwards[1].id, eliteAwards[1].typeName, eliteAwards[1].count)

			if (not eliteRecived) and self._info["is_highlight"..(i+1)] then
				self._eliteItem[i]:showBoxEffect("effects/leiji_light.ccbi", true, 0, 0, 0.6)
			else
				self._eliteItem[i]:removeEffect()
			end
		else
			if self._eliteItem[i] then
				self._eliteItem[i]:removeFromParent()
				self._eliteItem[i] = nil
			end
		end
	end
end

function QUIWidgetActivitySoulLetterAwardClient:setAwardState()
	local activityInfo = self._activityProxy:getActivityInfo()
	local levelUnlock = (activityInfo.level or 1) >= self._info.level

	local normalRecived = self._activityProxy:checkNormalAwardStatus(self._info.level)
	if self._info.normal_reward and levelUnlock then
		self._ccbOwner.sp_normal_ishave:setVisible(normalRecived)
		self._ccbOwner.sp_normal_highlight:setVisible(levelUnlock and (not normalRecived))
	else
		self._ccbOwner.sp_normal_ishave:setVisible(false)
		self._ccbOwner.sp_normal_highlight:setVisible(false)
	end

	local eliteUnlock = self._activityProxy:checkEliteUnlock()
	local eliteRecived = self._activityProxy:checkEliteAwardStatus(self._info.level)
	if self._info.rare_reward1 and eliteUnlock then
		self._ccbOwner.sp_elite_ishave:setVisible(eliteRecived)
		self._ccbOwner.sp_elite_highlight:setVisible(levelUnlock and (not eliteRecived))
	else
		self._ccbOwner.sp_elite_highlight:setVisible(false)
		self._ccbOwner.sp_elite_ishave:setVisible(false)
	end

	self._ccbOwner.node_normal_effect:setVisible(false)
	self._ccbOwner.node_elite_effect:setVisible(false)
	if levelUnlock then
		if (not normalRecived) and self._info.normal_reward then
			self._ccbOwner.node_normal_effect:setVisible(true)
		else
			self._ccbOwner.node_normal_effect:setVisible(false)
		end
		if eliteUnlock then
			self._ccbOwner.node_elite_effect:setVisible(not eliteRecived)
		end
	end
end
	
function QUIWidgetActivitySoulLetterAwardClient:registerItemBoxPrompt( index, list )
	local activityInfo = self._activityProxy:getActivityInfo()
	local levelUnlock = (activityInfo.level or 1) >= self._info.level
	local eliteUnlock = self._activityProxy:checkEliteUnlock()

	local function normaleShowItemInfo(x, y, itemBox, listView)
		local normalRecived = self._activityProxy:checkNormalAwardStatus(self._info.level)
		if normalRecived or levelUnlock == false then
			app.tip:itemTip(itemBox:getItemType(), itemBox:getItemId(), true)
		else
			self:_onTriggerClickNormal()
		end
	end
	local function eliteShowItemInfo(x, y, itemBox, listView)
		local eliteRecived = self._activityProxy:checkEliteAwardStatus(self._info.level)
		if eliteUnlock == false or eliteRecived or levelUnlock == false then
			app.tip:itemTip(itemBox:getItemType(), itemBox:getItemId(), true)
		else
			self:_onTriggerClickElite()
		end
	end
	if self._normalItem then
		list:registerItemBoxPrompt(index, 1, self._normalItem, -1, normaleShowItemInfo)
	end
	if self._eliteItem then
		for i = 1, #self._eliteItem do
			list:registerItemBoxPrompt(index, i+1, self._eliteItem[i], -2, eliteShowItemInfo)
		end
	end
end

function QUIWidgetActivitySoulLetterAwardClient:initGLLayer()
	self._glLayerIndex = 0

	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.ly_bg_size, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_bk, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_yk, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_normal_highlight, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_elite_highlight, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_title, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.btn_normal, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.btn_elite, self._glLayerIndex)
	
	if self._normalItem then
		self._glLayerIndex = self._normalItem:initGLLayer(self._glLayerIndex)
	end

	for _, value in ipairs(self._eliteItem) do
		self._glLayerIndex = value:initGLLayer(self._glLayerIndex)
	end

	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_normal_ishave, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_elite_ishave, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_normal_effect, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_elite_effect, self._glLayerIndex)
end

function QUIWidgetActivitySoulLetterAwardClient:getContentSize()
	return self._ccbOwner.ly_bg_size:getContentSize()
end

function QUIWidgetActivitySoulLetterAwardClient:_onTriggerClickNormal()
	local activityInfo = self._activityProxy:getActivityInfo()
	local levelUnlock = (activityInfo.level or 1) >= self._info.level
	local normalRecived = self._activityProxy:checkNormalAwardStatus(self._info.level)
	if self._info.normal_reward and levelUnlock and normalRecived == false then
		self:dispatchEvent({name = QUIWidgetActivitySoulLetterAwardClient.EVENT_CLICK_NORAML, info = self._info})
	end
end

function QUIWidgetActivitySoulLetterAwardClient:_onTriggerClickElite()
	local activityInfo = self._activityProxy:getActivityInfo()
	local levelUnlock = (activityInfo.level or 1) >= self._info.level

	local eliteUnlock = self._activityProxy:checkEliteUnlock()
	local eliteRecived = self._activityProxy:checkEliteAwardStatus(self._info.level)
	if self._info.rare_reward1 and levelUnlock and eliteUnlock and eliteRecived == false then
		self:dispatchEvent({name = QUIWidgetActivitySoulLetterAwardClient.EVENT_CLICK_ELITE, info = self._info})
	end
end

return QUIWidgetActivitySoulLetterAwardClient
