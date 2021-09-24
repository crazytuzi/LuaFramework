acCallsVoApi={
	status = nil,
	num = nil,
	phone = nil,
}

function acCallsVoApi:getAcVo()
	return activityVoApi:getActivityVo("calls")
end

-- 获取活动时间的现实格式
function acCallsVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.et)
	return timeStr
end

-- 得到订单号
function acCallsVoApi:getTId()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.tId ~= nil then
		return acVo.tId
	end
	return 0
end

function acCallsVoApi:setTId(tId)
	local acVo = self:getAcVo()
	if acVo ~= nil then
		acVo.tId = tId
	end
end

function acCallsVoApi:getMoneyCfg()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.money ~= nil and type(acVo.money) == "table" then
		return acVo.money
	end
	return nil
end

function acCallsVoApi:getMoneyCfgByIndex(index)
	local money = self:getMoneyCfg()
	if money ~= nil and SizeOfTable(money) >= index then
		return money[index]
	end
	return 0
end

function acCallsVoApi:getVipCfg()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.vip ~= nil and type(acVo.vip) == "table" then
		return acVo.vip
	end
	return nil
end

function acCallsVoApi:getVipCfgByIndex(index)
	local vip = self:getVipCfg()
	if vip ~= nil and SizeOfTable(vip) >= index then
		return vip[index]
	end
	return 0
end

function acCallsVoApi:getOnlineDayCfg()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.onlineDays ~= nil then
		return tonumber(acVo.onlineDays)
	end
	return 999
end

-- function acCallsVoApi:getLoginDay()
-- 	local dayNum=(G_getWeeTs(base.serverTime)-G_getWeeTs(playerVoApi:getRegdate()))/86400+1
-- 	if dayNum < 0 then
-- 		dayNum = 0
-- 	end
-- 	return dayNum
-- end

function acCallsVoApi:onLineAndGetAllReward()
	local newGiftsState=newGiftsVoApi:hasReward()
    if newGiftsState==-1 then
        return true
    end
    return false
end

function acCallsVoApi:getCanReward()
	local vipLevel=playerVoApi:getVipLevel()

	local index = 0
	local money = 0
	local moneyCfg = self:getMoneyCfg()
	local vipCfg = self:getVipCfg()
	if moneyCfg ~= nil and vipCfg ~= nil and self:onLineAndGetAllReward() == true then
		for i=1,SizeOfTable(vipCfg) do
			if vipLevel >= vipCfg[i] then
				index = i
				money = moneyCfg[i]
			end
		end
	end
	return index,money
end

-- 是否已领取奖励
function acCallsVoApi:checkIfHadReward()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.v > 0 then
		return true
	end
	return false
end

-- 当前是否有奖励可以领取
function acCallsVoApi:canReward()
	local had = self:checkIfHadReward()
	if had == false then
		local index,money = self:getCanReward()
		if index > 0 and money > 0 then
			return true
		end
	end
	return false
end


function acCallsVoApi:afterGetReward()
	local acVo = self:getAcVo()
	print("acVo: ",acVo, self:canReward(), self.status)
	if acVo ~= nil and self:canReward() == true and self.status == 0 then
		local index,money = self:getCanReward()
		acVo.v = index
	end
end

-- 后台推送状态数据，打开兑换面板时获得状态数据
function acCallsVoApi:afterPushStatus(data, showTips)
	print("acCallsVoApi:afterPushStatus: ", data.status, data.num, data.phone)
	if data.status ~= nil and data.num ~= nil and data.phone ~= nil then
		self.status = tonumber(data.status)--0为成功， 1为失败 2 正在充值中 3 未提交订单
		self.num = data.num
		self.phone = data.phone
		if showTips == true then
			self:showTips()
		end
		print("self.status == 0: ", self.status == 0)
		if self.status == 0 then
			self:afterGetReward()
		end
		local acVo = self:getAcVo()
		if acVo ~= nil then
			activityVoApi:updateShowState(acVo)
			acVo.stateChanged = true
		end
	end
end

function acCallsVoApi:showTips()
	local str = nil
	if self.status == 0 then
		str = getlocal("activity_calls_rechargeSucTip",{self.phone,self.num})
	elseif self.status == 1 then
		str = getlocal("activity_calls_rechargeFailTip")
	end
    if self.status == 0 or self.status == 1 then
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,28)	
	end
end

function acCallsVoApi:getStateAndData()
	if self.status ~= nil then
		return self.status,self.num,self.phone
	else
        local acVo = self:getAcVo()
		if acVo ~= nil and acVo.tState ~=nil then
			return acVo.tState,0,0
		end
	end
	return 1,0,0
end
function acCallsVoApi:clearAll()
    self.status = nil
	self.num = nil
	self.phone = nil
end

