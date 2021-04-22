-- 
-- Kumo.Wang
-- Silves押注记录界面
--

local QUIDialog = import(".QUIDialog")
local QUIDialogSilvesArenaStakeRecord = class("QUIDialogSilvesArenaStakeRecord", QUIDialog)

local QUIWidgetSilvesArenaStakeRecord = import("..widgets.QUIWidgetSilvesArenaStakeRecord")
local QListView = import("...views.QListView")

--初始化
function QUIDialogSilvesArenaStakeRecord:ctor(options)
    local ccbFile = "ccb/Dialog_SilvesArena_Stake_Record.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogSilvesArenaStakeRecord.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	self._ccbOwner.frame_tf_title:setString("押注记录")

	q.setButtonEnableShadow(self._ccbOwner.btn_close)


	if options then
		self._data = options.betList or {}
	end

	self:initListView()

	self._ccbOwner.node_no:setVisible(not next(self._data))
end

function QUIDialogSilvesArenaStakeRecord:initListView()
	local myTotalBetNum = 0 -- 押注的数量
	local myTotalGetNum = 0 -- 获得的数量
	local myTotalRatioNum = 0 -- 押对的数量
	local totalRatioNum = 0 -- 总开奖的数量
	
	for i, v in pairs(self._data) do
		local myBetNum, canGetNum, bingoState = self:getReward(v)
		v.localInfo = {}
		v.localInfo.myBetNum = myBetNum
		v.localInfo.canGetNum = canGetNum
		v.localInfo.bingoState = bingoState

		myTotalBetNum = myTotalBetNum + myBetNum 

		if bingoState == 1 or bingoState == 2 then
			totalRatioNum = totalRatioNum + 1
			if bingoState == 1 then
				myTotalRatioNum = myTotalRatioNum + 1
				myTotalGetNum = myTotalGetNum + canGetNum
			end
		end
	end
	self._ccbOwner.tf_bet_num:setString(myTotalBetNum)
	self._ccbOwner.tf_bet_award:setString(myTotalGetNum)

	local ratio = 0
	if totalRatioNum > 0 then
		ratio = myTotalRatioNum/totalRatioNum*100
	end
	local ratioStr = string.format("%.1f%%", ratio)
	self._ccbOwner.tf_bet_ratio:setString(ratioStr)

	table.sort(self._data, function(a, b)
		return a.currRound < b.currRound
	end)
	
	if not self._listView then
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._data[index]
	            local item = list:getItemFromCache(itemData.oType)
	            if not item then
	            	item = QUIWidgetSilvesArenaStakeRecord.new()
	            	isCacheNode = false
	            end
	            item:setInfo(itemData)
	            info.item = item
	            info.size = item:getContentSize()

                list:registerBtnHandler(index, "btn_detail", "_onTriggerDetail", nil, true)

	            return isCacheNode
	        end,
	        curOriginOffset = 2,
	        enableShadow = true,
	      	ignoreCanDrag = true,
	        totalNumber = #self._data,
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._listView:reload({#self._data})
	end
end

function QUIDialogSilvesArenaStakeRecord:getReward(info)
	local bingoState = 0 -- 押注结果。0:未开奖；1:押对；2:押输
	if info.scoreId > 0 then
		if info.scoreId == info.myScoreId then
			bingoState = 1
		else
			bingoState = 2
		end
	end

	local myBetNum = info.myBetAward or 0
	local canGetNum = info.myCanGetAward or 0

	if canGetNum == 0 then
		local totalMoney = 0
		local cellMoney = 1
		local scoreInfos = info.scoreDetailInfos or {}
		for i, scoreInfo in pairs(scoreInfos) do
			totalMoney = totalMoney + scoreInfo.totalMoney
			if scoreInfo.scoreId == info.myScoreId then
				cellMoney = scoreInfo.totalMoney
			end
		end
		canGetNum = math.ceil(myBetNum/cellMoney*totalMoney)
	end

	canGetNum = canGetNum - myBetNum
	if canGetNum < 0 then canGetNum = 0 end
	local maxBet = db:getConfigurationValue("team_arena_peak_max")
	local minBet = db:getConfigurationValue("team_arena_peak_min")
	if maxBet and canGetNum > myBetNum * maxBet then
		canGetNum = myBetNum * maxBet
	end
	if minBet and canGetNum < myBetNum * minBet then
		canGetNum = myBetNum * minBet
	end
	
	return myBetNum, canGetNum, bingoState
end

function QUIDialogSilvesArenaStakeRecord:_onTriggerClose()
    app.sound:playSound("common_cancel")
    self:playEffectOut()
end

function QUIDialogSilvesArenaStakeRecord:_backClickHandler()
	self:playEffectOut()
end

return QUIDialogSilvesArenaStakeRecord
