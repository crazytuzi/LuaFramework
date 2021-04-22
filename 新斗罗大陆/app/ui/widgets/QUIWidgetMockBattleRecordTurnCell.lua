


--
-- zxs
-- 统一战报
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMockBattleRecordTurnCell = class("QUIWidgetMockBattleRecordTurnCell", QUIWidget)
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIWidgetFloorIcon = import("..widgets.QUIWidgetFloorIcon")
local QRichText = import("...utils.QRichText")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

local reward_dis = 90
local reward_MidX = 160


function QUIWidgetMockBattleRecordTurnCell:ctor(options)
	local ccbFile = "ccb/Widget_MockBattle_RecordTurnCell.ccbi"
	local callBacks = {
		
	}
	QUIWidgetMockBattleRecordTurnCell.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._seasonType = remote.mockbattle:getMockBattleSeasonType()

end

function QUIWidgetMockBattleRecordTurnCell:initGLLayer(glLayerIndex)
	self._glLayerIndex = glLayerIndex or 1

	return self._glLayerIndex
end

function QUIWidgetMockBattleRecordTurnCell:resetAll()
	self._ccbOwner.node_reward_1:removeAllChildren()
	self._ccbOwner.node_reward_2:removeAllChildren()
	self._ccbOwner.node_reward_3:removeAllChildren()

end

function QUIWidgetMockBattleRecordTurnCell:setInfo(info ,report_type)
	self:resetAll()
	if not info then
		return
	end
	self._info = info

	self._ccbOwner.tf_round:setString(info.roundId)
	self._ccbOwner.tf_win:setString(info.winCount)
	self._ccbOwner.tf_lose:setString(info.loseCount)

	local index_ = 1
	if info.winCount > 0 then
		local score_item_num = 0
		for i=1,info.winCount  do
    		local score_num = db:getMockBattleScoreRewardById(i,self._seasonType)
    		score_item_num = score_item_num + tonumber(score_num)
		end

		if  score_item_num > 0 then
			local itemBox = QUIWidgetItemsBox.new()
		    itemBox:setPromptIsOpen(true)
		    itemBox:setScale(0.8)
		    itemBox:setGoodsInfo(70, "mock_battle_integral",tonumber(score_item_num))
		    self._ccbOwner["node_reward_"..index_]:addChild(itemBox)
		    index_ = index_ + 1
		end
	end

	if string.len(info.reward) ~= 0 then
		local rewardInfos = string.split(info.reward, ";")
		if next(rewardInfos) then 
			for i,v in ipairs(rewardInfos) do
				local reward_data = string.split(v, "^")
				if tonumber(reward_data[2]) ~= nil and tonumber(reward_data[2]) > 0 then 
					local itemBox = QUIWidgetItemsBox.new()
				    itemBox:setPromptIsOpen(true)
				    itemBox:setScale(0.8)
				    itemBox:setGoodsInfo(nil, reward_data[1],tonumber(reward_data[2]))
				    self._ccbOwner["node_reward_"..index_]:addChild(itemBox)
			    	index_ = index_ + 1
				end
			end
		end
	end

	index_ = index_ - 1
	if index_ == 1 then
		self._ccbOwner.node_reward_1:setPositionX(reward_MidX)
	elseif index_ == 2 then
		self._ccbOwner.node_reward_1:setPositionX(reward_MidX - reward_dis * 0.5)
		self._ccbOwner.node_reward_2:setPositionX(reward_MidX + reward_dis * 0.5)
	elseif index_ == 3 then
		self._ccbOwner.node_reward_1:setPositionX(reward_MidX - reward_dis)
		self._ccbOwner.node_reward_2:setPositionX(reward_MidX)
		self._ccbOwner.node_reward_2:setPositionX(reward_MidX + reward_dis)
	end

end

function QUIWidgetMockBattleRecordTurnCell:getContentSize()
	local size = self._ccbOwner.background:getContentSize()
	return CCSize(size.width, size.height+6)
end

return QUIWidgetMockBattleRecordTurnCell