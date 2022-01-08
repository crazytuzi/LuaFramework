--[[
******月卡数据管理类*******

	-- by quanhuan
	-- 2015-10-9 15:55:31
]]


local MonthCardManager = class("MonthCardManager")


MonthCardManager.BTN_STATUS_PAY = 1		--充值状态
MonthCardManager.BTN_STATUS_GET = 2		--领取状态
MonthCardManager.BTN_STATUS_GOT = 3		--已领状态

MonthCardManager.CARD_TYPE_1 = 1	--小月卡
MonthCardManager.CARD_TYPE_2 = 2	--大月卡

MonthCardManager.MONTH_CARD_LINGQU_COMPELTE = "MonthCardManager.MONTH_CARD_LINGQU_COMPELTE"
MonthCardManager.MONTH_CARD_INFO_UPDATE = "MonthCardManager.MONTH_CARD_INFO_UPDATE"
MonthCardManager.MONTH_CARD_RefeshAttr = "MonthCardManager.MONTH_CARD_RefeshAttr"

function MonthCardManager:ctor(data)

    TFDirector:addProto(s2c.CONTRACT_INFO, self, self.requestMonthCardCopmplete)
    TFDirector:addProto(s2c.BUY_CONTRACT_RESULT, self, self.chongzhiComplete)
    TFDirector:addProto(s2c.GET_CONTRACT_DAILY_REWARD_RESULT, self, self.lingquComplete)

    self.contractData = require('lua.table.t_s_contract_template')
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        self.rechargeList = require("lua.table.t_s_recharge_ios");
    else
        self.rechargeList = require("lua.table.t_s_recharge");
    end
	self:restart()
end

function MonthCardManager:restart()
	self.DataTable = {}
	for i=1,2 do
		self.DataTable[i] = {}
		self.DataTable[i].btnStatus = MonthCardManager.BTN_STATUS_PAY
		self.DataTable[i].day = 30
		self.DataTable[i].id = 1
		self.DataTable[i].startTime = 1
		self.DataTable[i].endTime = 1
		self.DataTable[i].lastGotRewardTime = 1
		self.DataTable[i].RMB = 0
		self.DataTable[i].YB = 0
	end

	local rechargeItem = self.rechargeList:objectByID(7)
	self.DataTable[1].RMB = rechargeItem.price
	self.DataTable[1].YB = self:getYuanbaoNum(MonthCardManager.CARD_TYPE_1)

	local rechargeItem1 = self.rechargeList:objectByID(11)
	self.DataTable[2].RMB = rechargeItem1.price
	self.DataTable[2].YB = self:getYuanbaoNum(MonthCardManager.CARD_TYPE_2)

	self:stopCheckTimer()
end

function MonthCardManager:chongzhi( card_type )

	if card_type == MonthCardManager.CARD_TYPE_1 then
		PayManager:pay(7,2)
	else
		PayManager:pay(11,3)
	end

end

function MonthCardManager:chongzhiComplete( event )

	hideLoading()
    -- toastMessage("月卡购买成功")
    toastMessage(localizable.MonthCardManager_buy_suc)
end

function MonthCardManager:lingqu( card_type )

	showLoading()
	if card_type == MonthCardManager.CARD_TYPE_1 then
		TFDirector:send(c2s.GET_CONTRACT_DAILY_REWARD, {1})
	else
		TFDirector:send(c2s.GET_CONTRACT_DAILY_REWARD, {2})
	end
	
end

function MonthCardManager:lingquComplete( event )

	hideLoading()
	TFDirector:dispatchGlobalEventWith(MonthCardManager.MONTH_CARD_LINGQU_COMPELTE, {event.data.id})
end

function MonthCardManager:getBtnStatus( card_type )
	return self.DataTable[card_type]
end

function MonthCardManager:openMonthCardLayer()

	--进入月卡界面之前刷新月卡信息
	self:CheckMonthCardStatus()
	local layer  = require("lua.logic.pay.MonthCardLayer"):new()
	AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
	AlertManager:show()

end

-- 刷新月卡状态信息
function MonthCardManager:CheckMonthCardStatus()
    
    local nowTime = MainPlayer:getNowtime() 
    local secInOneDay = 24 * 60 * 60 

    for i=1,2 do
    	if self.DataTable[i].btnStatus ~= MonthCardManager.BTN_STATUS_PAY then

    		if nowTime >= self.DataTable[i].endTime then
    			self.DataTable[i].btnStatus = MonthCardManager.BTN_STATUS_PAY
    			self.DataTable[i].day = 30
    		else
			    local lastRewardDayIndex    = calculateDayNumber(self.DataTable[i].lastGotRewardTime / 1000)
			    local nowDayIndex           = calculateDayNumber(nowTime)
			    local endDayIndex           = calculateDayNumber(self.DataTable[i].endTime/1000)
			    local startDayIndex         = calculateDayNumber(self.DataTable[i].startTime/1000)

			    if nowDayIndex > lastRewardDayIndex then
			    	self.DataTable[i].btnStatus = MonthCardManager.BTN_STATUS_GET
			    	self.DataTable[i].day = endDayIndex - nowDayIndex
			    else
			    	self.DataTable[i].btnStatus = MonthCardManager.BTN_STATUS_GOT
			    	self.DataTable[i].day = endDayIndex - nowDayIndex - 1
			    end

			    if self.DataTable[i].day < 0 then
	    			self.DataTable[i].btnStatus = MonthCardManager.BTN_STATUS_PAY
	    			self.DataTable[i].day = 30
			    end
    		end    		
    	end
    end
end

function MonthCardManager:IsMonthCardCanGet()
	--刷新月卡状态信息
	--需要查找其他文件
    self:CheckMonthCardStatus()

    for i=1,2 do
    	if self.DataTable[i].btnStatus == MonthCardManager.BTN_STATUS_GET then
	    	return true
    	end
    end
    return false
end

function MonthCardManager:requestMonthCardCopmplete( event )

	local infoTable = event.data.info

	-- print("OOOOOOOOOOOOOOOOOOOOOOOOOOO")
	-- print("OOOOOOOOOOOOOOOOOOOOOOOOOOO")
	-- print("OOOOOOOOOOOOOOOOOOOOOOOOOOO")
	-- print("OOOOOOOOOOOOOOOOOOOOOOOOOOO")
	-- print("infoTable",infoTable)

	for i=1,#infoTable do

		if infoTable[i].id == 1 then
			self.DataTable[1].btnStatus = MonthCardManager.BTN_STATUS_GET
			self.DataTable[1].id = infoTable[i].id 									--[	契约ID]
			self.DataTable[1].startTime = infoTable[i].startTime    				--[开始时间]
			self.DataTable[1].endTime = infoTable[i].endTime 						--[ 结束时间]
			self.DataTable[1].lastGotRewardTime = infoTable[i].lastGotRewardTime	--[上次领奖时间]
		elseif infoTable[i].id == 2 then
			self.DataTable[2].btnStatus = MonthCardManager.BTN_STATUS_GET
			self.DataTable[2].id = infoTable[i].id 									--[	契约ID]
			self.DataTable[2].startTime = infoTable[i].startTime    				--[开始时间]
			self.DataTable[2].endTime = infoTable[i].endTime 						--[ 结束时间]
			self.DataTable[2].lastGotRewardTime = infoTable[i].lastGotRewardTime	--[上次领奖时间]
		end
	end

	self:CheckMonthCardStatus()

	-- add by king
	self:startCheckTimer()

	TFDirector:dispatchGlobalEventWith(MonthCardManager.MONTH_CARD_INFO_UPDATE)
end

function MonthCardManager:getYuanbaoNum( card_type )

	local number = 0
	local index = 1
	if card_type == MonthCardManager.CARD_TYPE_1 then
		index = 1
	else
		index = 2
	end
	local template = self.contractData:getObjectAt(index)
	if template then
		local config = RewardConfigureData:GetRewardItemListById(template.reward_id)
		if config then
			for item in config:iterator() do
				number = item.number
			end
		end		
	end
	
	return number;
end

function MonthCardManager:isExistMonthCard(card_type)
	
	local nowDate = os.date("*t", MainPlayer:getNowtime())
	local endDate = os.date("*t", math.floor(self.DataTable[card_type].endTime/1000))

	if nowDate.year > endDate.year then
		return false
	elseif nowDate.year < endDate.year then
		return true
	elseif nowDate.month > endDate.month then
		return false
	elseif nowDate.month < endDate.month then
		return true
	elseif nowDate.day > endDate.day then
		return false
	else
		return true
	end
end

function MonthCardManager:stopCheckTimer()
	-- if self.monthCheckTimer then
 --        TFDirector:removeTimer(self.monthCheckTimer)
 --        self.monthCheckTimer = nil
 --    end
end


function MonthCardManager:startCheckTimer()

end

function MonthCardManager:buyBigMonthCardSuccess()
	CardRoleManager:refreshAllRolePower()

	TFDirector:dispatchGlobalEventWith(MonthCardManager.MONTH_CARD_RefeshAttr, {})
end


function MonthCardManager:refreshMonthCard()
	-- local bOwnMonth = self:isExistMonthCard(MonthCardManager.CARD_TYPE_2)

	-- if bOwnMonth then
	-- 	:buyBigMonthCardSuccess()
	-- end
	self:buyBigMonthCardSuccess()
	TFDirector:dispatchGlobalEventWith(MonthCardManager.MONTH_CARD_RefeshAttr, {})
end

return MonthCardManager:new()