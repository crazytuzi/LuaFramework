acRoulette4VoApi = {
	flag={0,0},
	isToday=true,
	lastListTime=0,
}

function acRoulette4VoApi:clearAll()
	self.flag={0,0}
	self.isToday=true
	self.lastListTime=0
end

function acRoulette4VoApi:getAcVo()
	return activityVoApi:getActivityVo("wheelFortune4")
end

function acRoulette4VoApi:clearRankList()
	local data={awardList={}}
	local vo=self:getAcVo()
	vo:updateSpecialData(data)
end
function acRoulette4VoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acRoulette4VoApi:getRouletteCfg()
	local vo=self:getAcVo()
	if vo and vo.acCfg then
		return vo.acCfg
	end
	return {}
end

function acRoulette4VoApi:getFlag(idx)
	return self.flag[idx]
end
function acRoulette4VoApi:setFlag(idx,value)
	if idx then
		if value then
			self.flag[idx]=value
		else
			self.flag[idx]=1
		end
	else
		if value then
			self.flag={value,value}
		else
			self.flag={1,1}
		end

	end
end

function acRoulette4VoApi:getLastListTime()
	return self.lastListTime
end
function acRoulette4VoApi:setLastListTime(time)
	self.lastListTime=time
end

-- function acRoulette4VoApi:getCostRewardNum()
-- 	local num=0
-- 	local cfg=self:getRouletteCfg()
-- 	if cfg and cfg.lotteryConsume then
-- 		local vo=self:getAcVo()
-- 		local consume=0
-- 		if vo and vo.consume then
-- 			consume=vo.consume
-- 		end
-- 		num=math.floor(consume/cfg.lotteryConsume)
-- 	end
-- 	return num
-- end
function acRoulette4VoApi:getUsedNum()
	local vo=self:getAcVo()
	local usedNum=0
	if vo then
		usedNum=vo.hasUsedNum or 0
		-- usedNum=vo.hasUsedNum+vo.feedNum
		-- if vo.hasUsedFreeNum then
		-- 	for k,v in pairs(vo.hasUsedFreeNum) do
		-- 		if v and tonumber(v)==1 then
		-- 			usedNum=usedNum+1
		-- 		end
		-- 	end
		-- end
	end
	return usedNum
end
function acRoulette4VoApi:getLeftNum()
	local vo=self:getAcVo()
	local leftNum=0
	-- local freeNum=0
	if vo and activityVoApi:isStart(vo) then
		leftNum=vo.leftNum or 0
		-- local isInFree,freeTab=self:isInFreeTime()
		-- if isInFree==true then
		-- 	if freeTab then
		-- 		for k,v in pairs(freeTab) do
		-- 			if v==1 and vo.hasUsedFreeNum then
		-- 				if vo.hasUsedFreeNum and vo.hasUsedFreeNum[k]==1 then
		-- 				else
		-- 					freeNum=freeNum+1
		-- 				end
		-- 			end
		-- 		end
		-- 	end
		-- end
		-- leftNum=leftNum+freeNum
		if leftNum<0 then
			leftNum=0
		end
	else
		leftNum=0
	end
	return leftNum--,freeNum
end

function acRoulette4VoApi:setTenUsedNum()
	local vo=self:getAcVo()
	if vo and vo.hasUsedNum then
		vo.hasUsedNum=vo.hasUsedNum+10
		activityVoApi:updateShowState(vo)
	end
end

function acRoulette4VoApi:checkCanPlay()
	local vo=self:getAcVo()
	local leftNum=self:getLeftNum() or 0
	local num=self:getCoinNum()
	if (leftNum>0 or num>0) and activityVoApi:isStart(vo) then
		return true
	end
	return false
end

function acRoulette4VoApi:checkCanTenPlay()
	local vo=self:getAcVo()
	local leftNum=self:getLeftNum() or 0
	local num=self:getCoinNum()
	if (leftNum+num)>=10 and activityVoApi:isStart(vo) then
		return true
	end
	return false
end

function acRoulette4VoApi:getCoinNum()
	local num=bagVoApi:getItemNumId(296) or 0
	return num
end
function acRoulette4VoApi:useCoin(num)
	bagVoApi:useItemNumId(296,num)
end

-- function acRoulette4VoApi:getRewardList()
-- 	local vo=self:getAcVo()
-- 	if(vo==nil)then
-- 		return nil
-- 	else
-- 		return vo.rewardList
-- 	end
-- end

function acRoulette4VoApi:getRankList()
	local vo=self:getAcVo()
	if vo and vo.rankList and SizeOfTable(vo.rankList)>0 then
		return vo.rankList
	else
		return {}
	end
end

-- function acRoulette4VoApi:getSelfRank()
-- 	local vo=self:getAcVo()
-- 	if vo and vo.rankList and SizeOfTable(vo.rankList)>0 then
-- 		for k,v in pairs(vo.rankList) do
-- 			if v and v[1] and tostring(v[1])==tostring(playerVoApi:getPlayerName()) then
-- 				return k
-- 			end
-- 		end
-- 	end
-- 	return "10+"
-- end

-- function acRoulette4VoApi:pointRewardUpdate(num)
-- 	local vo=self:getAcVo()
-- 	if vo and num then
-- 		vo.pointRewardNum=num
-- 		activityVoApi:updateShowState(vo)
-- 	end
-- end

function acRoulette4VoApi:canReward()
	local vo=self:getAcVo()
	if vo and activityVoApi:isStart(vo) then
		local leftNum=self:getLeftNum()
		if leftNum>0 then
			return true
		end
	-- 	return self:checkCanPlay()
	-- else
	-- 	if self:rankCanReward()>0 then
	-- 		return true
	-- 	else
	-- 		return false
	-- 	end
	end
	return false
end

function acRoulette4VoApi:isRouletteToday()
	local vo=self:getAcVo()
	if vo and vo.lastTime then
		if self.isToday~=G_isToday(vo.lastTime) and G_isToday(vo.lastTime)==false then	
			-- vo.consume=0
	        vo.hasUsedNum=0
	        -- vo.point=0
	        -- vo.hasUsedFreeNum=0
	        -- vo.pointRewardNum=0

	        vo.leftNum=0
	        vo.hasUsedFreeNum={}
	        vo.feedNum=0
	        vo.rechargeNum=0
	        vo.lastTime=G_getWeeTs(base.serverTime)

        	self.isToday=false
        	self:setFlag(nil,0)

        	activityVoApi:updateShowState(vo)
        	vo.stateChanged=true

        	return false
		end
	end
	return true
end

-- function acRoulette4VoApi:rankCanReward()
-- 	local cfg=self:getRouletteCfg()
-- 	local vo=self:getAcVo()
-- 	-- if cfg and cfg.rankPoint and vo and  vo.listRewardNum==0 and self:acIsStop()==true and activityVoApi:isStart(vo) then
-- 	if cfg and cfg.rankPoint and vo and  vo.listRewardNum==0 and activityVoApi:isStart(vo) then
-- 		if vo.totalPoint and vo.totalPoint>=cfg.rankPoint then
-- 			if vo.rankList and SizeOfTable(vo.rankList)>0 then
-- 				for k,v in pairs(vo.rankList) do
-- 					if v and v[1] and tostring(v[1])==tostring(playerVoApi:getPlayerName()) then
-- 						return tonumber(k) or 0
-- 					end
-- 				end
-- 			end
-- 		end
-- 	end
-- 	return 0
-- end
-- function acRoulette4VoApi:setListRewardNum()
-- 	local vo=self:getAcVo()
-- 	if vo and vo.listRewardNum then
-- 		vo.listRewardNum=1
-- 		activityVoApi:updateShowState(vo)
-- 		vo.stateChanged=true
-- 	end
-- end

function acRoulette4VoApi:getIndexByNameAndType(name,type,num)
	local cfg=self:getRouletteCfg()
	if cfg and cfg.pool then
		local awardTab=FormatItem(cfg.pool,nil,true)
		for k,v in pairs(awardTab) do
			if v and tostring(v.type)==tostring(type) and v.name==name and tonumber(v.num)==tonumber(num) then
				return k
			end
		end
	end
	return 0
end

function acRoulette4VoApi:getTimeTab()
	local timeTab={}
	local cfg=self:getRouletteCfg()
	local function formatNum(num)
		if tonumber(num) and tonumber(num)<10 then
			return "0"..num
		end
		return num
	end
	if cfg.startTime and cfg.durationTime then
		local startTime=cfg.startTime
		local durationTime=cfg.durationTime
		for k,v in pairs(startTime) do
			local index=tonumber(RemoveFirstChar(k))
			local sHour,sMinute=v[1],v[2] 
			local startPoint=sHour*3600+sMinute*60
			local endPoint=startPoint+durationTime
			local eHour,eMinute=math.floor(endPoint/3600),math.floor((endPoint%3600)/60)
			if tonumber(sHour)<10 then

			end
			local startTime=formatNum(sHour)..":"..formatNum(sMinute)
			local endTime=formatNum(eHour)..":"..formatNum(eMinute)
			local timeStr=startTime.."--"..endTime
			timeTab[index]=timeStr
			-- table.insert(timeTab,timeStr)
		end
	end
	return timeTab
end

function acRoulette4VoApi:isInFreeTime()
	local dayTime=base.serverTime-G_getWeeTs(base.serverTime)
	local cfg=self:getRouletteCfg()
	local isInFree=false
	-- local freeTab={f1=0,f2=0}
	if cfg.startTime and cfg.durationTime then
		local acVo = self:getAcVo()
		for k,v in pairs(cfg.startTime) do
			if v and v[1] and v[2] then
				local sHour,sMinute=v[1],v[2]
				local startPoint=sHour*3600+sMinute*60
				local endPoint=startPoint+cfg.durationTime
				if dayTime>=startPoint and dayTime<=endPoint then
					if acVo and acVo.hasUsedFreeNum then
						-- print("k",k)
						-- print("acVo.hasUsedFreeNum[k]",acVo.hasUsedFreeNum[k])
						if acVo.hasUsedFreeNum[k]==1 then
						else
							isInFree=true
						end
					end
					-- freeTab[k]=1
				end
			end
		end
	end

	-- local freeTab=cfg.freetime
	-- local isInFree=false
	-- local isFreeTab={0,0}
	-- for k,v in pairs(freeTab) do
	-- 	local startTime=v[1]
	-- 	local endTime=v[2]

	-- 	local startTab=Split(startTime,":")
	-- 	local endTab=Split(endTime,":")

	-- 	local sHour,sMinute=startTab[1],startTab[2]
	-- 	local eHour,eMinute=endTab[1],endTab[2]

	-- 	local startPoint=sHour*3600+sMinute*60
	-- 	local endPoint=eHour*3600+eHour*60
	-- 	if dayTime>=startPoint and dayTime<=endPoint then
	-- 		freeTab[k]=1
	-- 		isInFree=true
	-- 	end
	-- end

	return isInFree--,freeTab
end

-- 玩家在线充值后，后台将新的充值金额推给前台，前台要强制更新数据
function acRoulette4VoApi:addMoney(money)
	local acVo = self:getAcVo()
	local cfg=self:getRouletteCfg()
	if cfg and acVo and acVo.rechargeNum then
		local num=0
		acVo.rechargeNum=acVo.rechargeNum+money
		if acVo.rechargeNum>=cfg.lotteryConsume then
			num=math.floor(acVo.rechargeNum/cfg.lotteryConsume)
			acVo.rechargeNum=(acVo.rechargeNum%cfg.lotteryConsume)
		end
		acVo.leftNum=acVo.leftNum+num
		acVo.lastTime=G_getWeeTs(base.serverTime)
		self:setFlag(1,0)
		activityVoApi:updateShowState(acVo)
		acVo.stateChanged = true -- 强制更新数据
	end
end

function acRoulette4VoApi:addNum()
	local vo=self:getAcVo()
	if vo and vo.feedNum and vo.feedNum==0 then
		vo.leftNum=vo.leftNum+1
		vo.feedNum=1
		activityVoApi:updateShowState(vo)
		vo.stateChanged = true -- 强制更新数据
	end
end

-- function acRoulette4VoApi:acIsStop()
-- 	local vo=self:getAcVo()
-- 	if vo and base.serverTime<(vo.et-24*3600) then
-- 		return false
-- 	end
-- 	return true
-- end
-- function acRoulette4VoApi:isEnd()
-- 	local vo=self:getAcVo()
-- 	if vo and base.serverTime<vo.et then
-- 		return false
-- 	end
-- 	return true
-- end

