-- @Author: liaoxianbo
-- @Date:   2020-04-13 14:50:16
-- @Last Modified by:   DELL
-- @Last Modified time: 2020-04-14 10:47:47
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSoulTowerRankAwardCell = class("QUIWidgetSoulTowerRankAwardCell", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

QUIWidgetSoulTowerRankAwardCell.AWARDS_IS_NONE = "AWARDS_IS_NONE"
QUIWidgetSoulTowerRankAwardCell.AWARDS_IS_DONE = "AWARDS_IS_DONE"

function QUIWidgetSoulTowerRankAwardCell:ctor(options)
	local ccbFile = "ccb/Widget_SoulTower_RankAward.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetSoulTowerRankAwardCell.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._state = QUIWidgetSoulTowerRankAwardCell.AWARDS_IS_NONE 
	self._itemBox = {}

end

function QUIWidgetSoulTowerRankAwardCell:onEnter()
end

function QUIWidgetSoulTowerRankAwardCell:onExit()
end

function QUIWidgetSoulTowerRankAwardCell:setInfo(param)
	self._awardInfo = param.awardInfo or {}
	local items = nil
	if param.awardsType == 1 then
		items = db:getLuckyDraw(self._awardInfo.local_rank_reward)
	elseif param.awardsType == 2 then
		items = db:getLuckyDraw(self._awardInfo.global_rank_reward)
	end

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

function QUIWidgetSoulTowerRankAwardCell:setConditionState(isDone, rankString, titleString)
	self._ccbOwner.title:setString(titleString or "")
	self._ccbOwner.rank:setString(rankString or "")

	self._ccbOwner.finish:setVisible(false)
	self._ccbOwner.notFinish:setVisible(false)
	if isDone then
		self._ccbOwner.finish:setVisible(true)
		self._state = QUIWidgetSoulTowerRankAwardCell.AWARDS_IS_DONE
	else
		self._ccbOwner.notFinish:setVisible(true)
		self._state = QUIWidgetSoulTowerRankAwardCell.AWARDS_IS_NONE
	end
end

function QUIWidgetSoulTowerRankAwardCell:_onTriggerClick()
	if self._state == QUIWidgetSoulTowerRankAwardCell.AWARDS_IS_READY then
		self:dispatchEvent({name = QUIWidgetSoulTowerRankAwardCell.EVENT_CLICK})
	end
end

function QUIWidgetSoulTowerRankAwardCell:getContentSize()
		return self._ccbOwner.cellsize:getContentSize()
end

return QUIWidgetSoulTowerRankAwardCell
