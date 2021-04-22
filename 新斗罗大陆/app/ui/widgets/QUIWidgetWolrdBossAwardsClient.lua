-- @Author: xurui
-- @Date:   2016-10-24 10:40:58
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-11-06 14:37:47
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetWolrdBossAwardsClient = class("QUIWidgetWolrdBossAwardsClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

QUIWidgetWolrdBossAwardsClient.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetWolrdBossAwardsClient:ctor(options)
	local ccbFile = "ccb/Widget_Panjun_Boss_jiangli.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
	}
	QUIWidgetWolrdBossAwardsClient.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._state = QUIWidgetWolrdBossAwardsClient.AWARDS_IS_NONE 
	self._itemBox = {}
end

function QUIWidgetWolrdBossAwardsClient:onEnter()
end

function QUIWidgetWolrdBossAwardsClient:onExit()
end

function QUIWidgetWolrdBossAwardsClient:setInfo(param)
	self._index = param.index
	self._awardInfo = param.awardInfo or {}
	
	-- set awards item box
	local items = QStaticDatabase:sharedDatabase():getLuckyDraw(self._awardInfo.luckyDraw)
	if items == nil then return end

	for i = 1, 4 do
		if items["type_"..i] then
			if self._itemBox[i] == nil then
				self._itemBox[i] = QUIWidgetItemsBox.new()
				 self._ccbOwner["item"..i]:addChild(self._itemBox[i])
			end
			self._itemBox[i]:setGoodsInfo(items["id_"..i], items["type_"..i], items["num_"..i])
			self._itemBox[i]:setPromptIsOpen(true)
			self._itemBox[i]:setVisible(true)
		else
			if self._itemBox[i] ~= nil then
				self._itemBox[i]:setVisible(false)
			end
		end
	end

	--set condition
	self:setConditionState(param.condition, param.rankString, param.titleString)
end

function QUIWidgetWolrdBossAwardsClient:setConditionState(condition, rankString, titleString)
	self._ccbOwner.tf_award_title:setString(titleString or "")
	self._ccbOwner.tf_progress:setString(rankString or "")

	self._ccbOwner.node_ready:setVisible(false)
	self._ccbOwner.node_done:setVisible(false)
	self._ccbOwner.node_none:setVisible(false)
	self._ccbOwner.sp_ready:setVisible(false)
	if self._awardInfo.state == remote.worldBoss.AWARDS_IS_READY then
		self._ccbOwner.node_ready:setVisible(true)
		self._ccbOwner.sp_ready:setVisible(true)
	elseif self._awardInfo.state == remote.worldBoss.AWARDS_IS_DONE then
		self._ccbOwner.node_done:setVisible(true)
	elseif self._awardInfo.state == remote.worldBoss.AWARDS_IS_NONE then
		self._ccbOwner.node_none:setVisible(true)
	end
end

function QUIWidgetWolrdBossAwardsClient:_onTriggerClick(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_get) == false then return end
	self:dispatchEvent({name = QUIWidgetWolrdBossAwardsClient.EVENT_CLICK, awardInfo = self._awardInfo})
end

function QUIWidgetWolrdBossAwardsClient:getContentSize()
	return self._ccbOwner.cell_size:getContentSize()
end

function QUIWidgetWolrdBossAwardsClient:_backClickHandler()
    self:_onTriggerClose()
end

function QUIWidgetWolrdBossAwardsClient:_onTriggerClose()
	self:popSelf()
end

return QUIWidgetWolrdBossAwardsClient