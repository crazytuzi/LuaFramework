-- @Author: xurui
-- @Date:   2016-10-25 16:13:36
-- @Last Modified by:   xurui
-- @Last Modified time: 2016-10-25 16:33:10
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetWorldBossRankAwardClient = class("QUIWidgetWorldBossRankAwardClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

QUIWidgetWorldBossRankAwardClient.AWARDS_IS_NONE = "AWARDS_IS_NONE"
QUIWidgetWorldBossRankAwardClient.AWARDS_IS_DONE = "AWARDS_IS_DONE"

function QUIWidgetWorldBossRankAwardClient:ctor(options)
	local ccbFile = "ccb/Widget_WineGod_jifen.ccbi"
	local callBack = {}
	QUIWidgetWorldBossRankAwardClient.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._state = QUIWidgetWorldBossRankAwardClient.AWARDS_IS_NONE 
	self._itemBox = {}
end

function QUIWidgetWorldBossRankAwardClient:onEnter()
end

function QUIWidgetWorldBossRankAwardClient:onExit()
end

function QUIWidgetWorldBossRankAwardClient:setInfo(param)
	self._awardInfo = param.awardInfo or {}
	
	-- set awards item box
	local items = QStaticDatabase:sharedDatabase():getLuckyDraw(self._awardInfo.intrusion_rank)
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
	self:setConditionState(param.isDone, param.rankString, param.titleString)
end

function QUIWidgetWorldBossRankAwardClient:setConditionState(isDone, rankString, titleString)
	self._ccbOwner.title:setString(titleString or "")
	self._ccbOwner.rank:setString(rankString or "")

	self._ccbOwner.finish:setVisible(false)
	self._ccbOwner.notFinish:setVisible(false)
	if isDone then
		self._ccbOwner.finish:setVisible(true)
		self._state = QUIWidgetWorldBossRankAwardClient.AWARDS_IS_DONE
	else
		self._ccbOwner.notFinish:setVisible(true)
		self._state = QUIWidgetWorldBossRankAwardClient.AWARDS_IS_NONE
	end
end

function QUIWidgetWorldBossRankAwardClient:_onTriggerClick()
	if self._state == QUIWidgetWorldBossRankAwardClient.AWARDS_IS_READY then
		self:dispatchEvent({name = QUIWidgetWorldBossRankAwardClient.EVENT_CLICK})
	end
end

function QUIWidgetWorldBossRankAwardClient:getContentSize()
	return self._ccbOwner.cellsize:getContentSize()
end

function QUIWidgetWorldBossRankAwardClient:_backClickHandler()
    self:_onTriggerClose()
end

function QUIWidgetWorldBossRankAwardClient:_onTriggerClose()
	self:popSelf()
end

return QUIWidgetWorldBossRankAwardClient