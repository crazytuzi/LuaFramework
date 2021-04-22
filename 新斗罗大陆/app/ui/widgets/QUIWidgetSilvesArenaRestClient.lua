--
-- Kumo.Wang
-- 西尔维斯大斗魂场休赛期主界面
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilvesArenaRestClient = class("QUIWidgetSilvesArenaRestClient", QUIWidget)

local QListView = import("...views.QListView")
local QUIWidgetActorDisplay = import(".actorDisplay.QUIWidgetActorDisplay")

local QUIWidgetSilvesArenaRestRankCell = import(".QUIWidgetSilvesArenaRestRankCell")
local QUIWidgetSilvesArenaRestWinner = import(".QUIWidgetSilvesArenaRestWinner")

QUIWidgetSilvesArenaRestClient.EVENT_CLIENT = "QUIWIDGETSILVESARENARESTCLIENT.EVENT_CLIENT"

QUIWidgetSilvesArenaRestClient.VIEW_ON = 1
QUIWidgetSilvesArenaRestClient.VIEW_OFF = -1

function QUIWidgetSilvesArenaRestClient:ctor(options)
	local ccbFile = "ccb/Widget_SilvesArena_Rest.ccbi"
  	local callBacks = {
        -- {ccbCallbackName = "onTriggerInfo", callback = handler(self, self._onTriggerInfo)},
  	}
	QUIWidgetSilvesArenaRestClient.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self:_init()
end

function QUIWidgetSilvesArenaRestClient:onEnter()
	QUIWidgetSilvesArenaRestClient.super.onEnter(self)

	if q.isEmpty(remote.silvesArena.peakTeamInfo) then
		remote.silvesArena:silvesArenaGetMainInfoRequest(function()
			if self._ccbView then
				self:update()
			end
		end)
	else
		self:update()
	end
end

function QUIWidgetSilvesArenaRestClient:onExit()
	QUIWidgetSilvesArenaRestClient.super.onExit(self)
end

function QUIWidgetSilvesArenaRestClient:getClassName()
	return "QUIWidgetSilvesArenaRestClient"
end

function QUIWidgetSilvesArenaRestClient:update()
	if q.isEmpty(remote.silvesArena.peakTeamInfo) then
		self._ccbOwner.node_winner:setVisible(false)
		self._ccbOwner.node_no_winner:setVisible(true)
		self._ccbOwner.node_no_rank:setVisible(true)
		self._ccbOwner.node_rank:setVisible(false)
		self._ccbOwner.node_npc_fld:removeAllChildren()
		local avatar = QUIWidgetActorDisplay.new(1013)
		avatar:setScaleX(-1)
		self._ccbOwner.node_npc_fld:addChild(avatar)
	else
		self._ccbOwner.node_winner:setVisible(true)
		self._ccbOwner.node_no_winner:setVisible(false)
		self._ccbOwner.node_no_rank:setVisible(false)
		self._ccbOwner.node_rank:setVisible(true)
		self._ccbOwner.node_npc_fld:removeAllChildren()
		self:_updateView()
	end
end

function QUIWidgetSilvesArenaRestClient:_init()
	self._firstTeamInfo = {}
	self._secondTeamInfo = {}
	self._thirdTeamInfo = {}
	self._teamInfoList = {}

	self._isInfoON = self.VIEW_ON
	self._nodeInfoY = 190
	self._ccbOwner.node_info:setPosition(360, self._nodeInfoY)

	self._ccbOwner.node_winner:setVisible(false)
	self._ccbOwner.node_no_winner:setVisible(false)
end

function QUIWidgetSilvesArenaRestClient:_updateView()
	self:_updateWinnerView()
	-- self:_updateRankView()
end

function QUIWidgetSilvesArenaRestClient:_updateWinnerView()
	if (q.isEmpty(self._firstTeamInfo) or q.isEmpty(self._secondTeamInfo) or q.isEmpty(self._thirdTeamInfo)) and not q.isEmpty(remote.silvesArena.peakTeamInfo) then
		for _, teamInfo in ipairs(remote.silvesArena.peakTeamInfo) do
			if teamInfo.currRound == 5 then
				self._firstTeamInfo = teamInfo
			elseif teamInfo.currRound == 4 then
				self._secondTeamInfo = teamInfo
			elseif teamInfo.isThirdRound then
				self._thirdTeamInfo = teamInfo
			end
		end
	end

	self._ccbOwner.node_winner_1:removeAllChildren()
	if not q.isEmpty(self._firstTeamInfo) then
		local winner = QUIWidgetSilvesArenaRestWinner.new({info = self._firstTeamInfo, index = 1})
		self._ccbOwner.node_winner_1:addChild(winner)
	end

	self._ccbOwner.node_winner_2:removeAllChildren()
	if not q.isEmpty(self._secondTeamInfo) then
		local winner = QUIWidgetSilvesArenaRestWinner.new({info = self._secondTeamInfo, index = 2})
		self._ccbOwner.node_winner_2:addChild(winner)
	end

	self._ccbOwner.node_winner_3:removeAllChildren()
	if not q.isEmpty(self._thirdTeamInfo) then
		local winner = QUIWidgetSilvesArenaRestWinner.new({info = self._thirdTeamInfo, index = 3})
		self._ccbOwner.node_winner_3:addChild(winner)
	end
end

-- function QUIWidgetSilvesArenaRestClient:_updateRankView()
-- 	if q.isEmpty(remote.silvesArena.peakTeamInfo) then
-- 		return
-- 	end

-- 	if q.isEmpty(self._teamInfoList) then
-- 		self._teamInfoList = remote.silvesArena.peakTeamInfo or {}
-- 		table.sort(self._teamInfoList, function(a, b)
-- 			if a.currRound ~= b.currRound then
-- 				return a.currRound > b.currRound
-- 			elseif a.isThirdRound ~= b.isThirdRound then
-- 				return a.isThirdRound
-- 			elseif a.peakWinCount ~= b.peakWinCount then
-- 				return a.peakWinCount > b.peakWinCount
-- 			else
-- 				return a.position < b.position
-- 			end
-- 		end)
-- 	end

-- 	self:_updateListView()
-- end

-- function QUIWidgetSilvesArenaRestClient:_updateListView()
-- 	if not self._listViewLayout then
-- 		local cfg = {
-- 			renderItemCallBack = handler(self, self._renderItemHandler),
-- 			isVertical = true,
-- 			ignoreCanDrag = true,
-- 			spaceY = 0,
-- 	        totalNumber = #self._teamInfoList,
-- 		}
-- 		self._listViewLayout = QListView.new(self._ccbOwner.sheet_layout, cfg)
-- 	else
-- 		self._listViewLayout:refreshData()
-- 	end
-- end

-- function QUIWidgetSilvesArenaRestClient:_renderItemHandler(list, index, info )
--     local isCacheNode = true
--     local itemData = self._teamInfoList[index]

--     local item = list:getItemFromCache()
--     if not item then
--     	item = QUIWidgetSilvesArenaRestRankCell.new()
--         isCacheNode = false
--     end

--     item:setInfo(itemData, index)
--     info.item = item
--     info.size = item:getContentSize()

--     list:registerClickHandler(index, "self", function()
--              		return true
--              	end, nil, handler(self, self._onTriggerRank))

--     return isCacheNode
-- end

-- function QUIWidgetSilvesArenaRestClient:_onTriggerRank()
-- 	self:dispatchEvent({name = QUIWidgetSilvesArenaRestClient.EVENT_CLIENT})
-- end

-- function QUIWidgetSilvesArenaRestClient:_onTriggerInfo()
--     app.sound:playSound("common_small")
-- 	self._isInfoON = - self._isInfoON
-- 	self:_doInfoViewEffect(true)
-- end

-- function QUIWidgetSilvesArenaRestClient:_doInfoViewEffect(isAnimation)
--     self._ccbOwner.node_info:stopAllActions()
--     local posX = 560 -- off
--     if self._isInfoON == self.VIEW_ON then
--     	posX = 360 -- on
--     end
--     if isAnimation then
--     	local actions = CCArray:create()
--     	actions:addObject( CCMoveTo:create(0.2, ccp(posX, self._nodeInfoY)) )
--     	actions:addObject( CCCallFunc:create(function()
--             if self._isInfoON == self.VIEW_ON then
-- 		    	self._ccbOwner.tf_direction:setScaleX(1)
-- 		    else
-- 		    	self._ccbOwner.tf_direction:setScaleX(-1)
-- 		    end
-- 		    self._listViewLayout:resetTouchRect()
--         end) )
--     	self._ccbOwner.node_info:runAction( CCSequence:create(actions) )
-- 	else
--     	self._ccbOwner.node_info:setPosition(posX, self._nodeInfoY)
--     	if self._isInfoON == self.VIEW_ON then
-- 	    	self._ccbOwner.tf_direction:setScaleX(1)
-- 	    else
-- 	    	self._ccbOwner.tf_direction:setScaleX(-1)
-- 	    end
-- 	    self._listViewLayout:resetTouchRect()
-- 	end
-- end

return QUIWidgetSilvesArenaRestClient