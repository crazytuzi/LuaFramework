--
-- zxs
-- 精英赛下注记录
--

local QUIDialog = import(".QUIDialog")
local QUIDialogSanctuaryBetRecord = class("QUIDialogSanctuaryBetRecord", QUIDialog)
local QUIWidgetSanctuaryBetRecord = import("..widgets.sanctuary.QUIWidgetSanctuaryBetRecord")
local QListView = import("...views.QListView")

--初始化
function QUIDialogSanctuaryBetRecord:ctor(options)
    local ccbFile = "ccb/Dialog_Sanctuary_record.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogSanctuaryBetRecord.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	self._data = options.betList or {}
	self:initListView()

	self._ccbOwner.frame_tf_title:setString("押注记录")
	self._ccbOwner.node_no:setVisible(not next(self._data))
	q.setButtonEnableShadow(self._ccbOwner.btn_close)
end

function QUIDialogSanctuaryBetRecord:initListView()
	local myTotalBetNum = 0
	local myTotalGetNum = 0
	local myTotalRatioNum = 0
	local totalRatioNum = 0
	for i, v in pairs(self._data) do
		local myBetNum, canGetNum, awardNum, winNum, loseNum = self:getReward(v)
		v.localInfo = {}
		v.localInfo.myBetNum = myBetNum
		v.localInfo.canGetNum = canGetNum
		v.localInfo.awardNum = awardNum
		v.localInfo.winNum = winNum
		v.localInfo.loseNum = loseNum

		myTotalBetNum = myTotalBetNum + myBetNum 
		if awardNum == 1 or awardNum == 2 then
			totalRatioNum = totalRatioNum + 1
			if awardNum == 1 then
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

	-- body
	if not self._listView then
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._data[index]
	            local item = list:getItemFromCache(itemData.oType)
	            if not item then
	            	item = QUIWidgetSanctuaryBetRecord.new()
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

function QUIDialogSanctuaryBetRecord:getReward(info)
	local awardNum = 0
	local winNum = 0
	local loseNum = 0
	local scoreList = info.scoreList or {}
	if next(scoreList) then
		for i, v in ipairs(scoreList) do
			if v == true then
				winNum = winNum + 1
			else
				loseNum = loseNum + 1
			end
		end
		local scoreId = 0
		for i, score in ipairs(remote.sanctuary.SCORE_MAP) do
			if score[1] == winNum and score[2] == loseNum then
				scoreId = i
				break
			end
		end
		if scoreId == info.myScoreId then
			awardNum = 1
		else
			awardNum = 2
		end
	else
		awardNum = 0
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
	if canGetNum > myBetNum*10 then
		canGetNum = myBetNum*10
	end
	if canGetNum < myBetNum then
		canGetNum = myBetNum
	end
	
	return myBetNum, canGetNum, awardNum, winNum, loseNum
end

function QUIDialogSanctuaryBetRecord:_onTriggerClose()
    app.sound:playSound("common_cancel")
    self:playEffectOut()
end

function QUIDialogSanctuaryBetRecord:_backClickHandler()
	self:playEffectOut()
end

return QUIDialogSanctuaryBetRecord
