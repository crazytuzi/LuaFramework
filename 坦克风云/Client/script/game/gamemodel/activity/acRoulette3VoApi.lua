acRoulette3VoApi = {
	flag={0,0,0},
	isToday=true,
	lastListTime=0,
}

function acRoulette3VoApi:clearAll()
	self.flag={0,0,0}
	self.isToday=true
	self.lastListTime=0
end

function acRoulette3VoApi:getAcVo()
	return activityVoApi:getActivityVo("wheelFortune3")
end

function acRoulette3VoApi:clearRankList()
	local data={rankList={}}
	local vo=self:getAcVo()
	vo:updateSpecialData(data)
end
function acRoulette3VoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acRoulette3VoApi:getRouletteCfg()
	local vo=self:getAcVo()
	if vo and vo.acCfg then
		return vo.acCfg
	end
	return {}
end

function acRoulette3VoApi:getFlag(idx)
	return self.flag[idx]
end
function acRoulette3VoApi:setFlag(idx,value)
	if idx then
		if value then
			self.flag[idx]=value
		else
			self.flag[idx]=1
		end
	else
		if value then
			self.flag={value,value,value}
		else
			self.flag={1,1,1}
		end

	end
end

function acRoulette3VoApi:getLastListTime()
	return self.lastListTime
end
function acRoulette3VoApi:setLastListTime(time)
	self.lastListTime=time
end

function acRoulette3VoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end
function acRoulette3VoApi:getRewardTimeStr( )
	local vo  = self:getAcVo()
	local reTimeStr = activityVoApi:getActivityRewardTimeStr(vo.acEt,60,86400)
	return reTimeStr
end
function acRoulette3VoApi:getCostRewardNum()
	local num=0
	local cfg=self:getRouletteCfg()
	if cfg and cfg.lotteryConsume then
		local vo=self:getAcVo()
		local consume=0
		if vo and vo.consume then
			consume=vo.consume
		end
		num=math.floor(consume/cfg.lotteryConsume)
	end
	return num
end
function acRoulette3VoApi:getUsedNum()
	local vo=self:getAcVo()
	local usedNum=0
	if vo and vo.hasUsedFreeNum and vo.hasUsedNum then
		usedNum=vo.hasUsedFreeNum+vo.hasUsedNum
	end
	return usedNum
end
function acRoulette3VoApi:getLeftNum()
	local totleNum=self:getCostRewardNum()
	local vo=self:getAcVo()
	local leftNum=0
	local freeNum=0
	if acRoulette3VoApi:acIsStop()==false then 
		local hasUsedNum=self:getUsedNum()
		if vo and vo.hasUsedFreeNum and vo.hasUsedNum then
			if playerVoApi:getVipLevel()~=nil and playerVoApi:getVipLevel()>0 then
				freeNum=2-vo.hasUsedFreeNum
				-- freeNum=freeNum+1
			else
				freeNum=1-vo.hasUsedFreeNum
			end
			if freeNum<0 then
				freeNum=0
			end
			-- if G_isToday(vo.lastTime)==false then
			-- 	freeNum=freeNum+1
			-- end
			leftNum=totleNum+freeNum-vo.hasUsedNum--hasUsedNum
		end
		if leftNum<0 then
			leftNum=0
		end
	else
		leftNum=0
	end
	return leftNum
end

function acRoulette3VoApi:isFree()
	local vo=self:getAcVo()
	if vo and vo.lastTime and G_isToday(vo.lastTime)==false then
		return true
	else
		local freeNum=0
		if vo and vo.hasUsedFreeNum then
			if playerVoApi:getVipLevel()~=nil and playerVoApi:getVipLevel()>0 then
				freeNum=2-vo.hasUsedFreeNum
			else
				freeNum=1-vo.hasUsedFreeNum
			end
			if freeNum<0 then
				freeNum=0
			end
		end
		if freeNum>0 then
			return true
		end
	end
	return false
end

function acRoulette3VoApi:setTenUsedNum()
	local vo=self:getAcVo()
	if vo and vo.hasUsedNum then
		vo.hasUsedNum=vo.hasUsedNum+10
		activityVoApi:updateShowState(vo)
	end
end

function acRoulette3VoApi:checkCanPlay()
	local vo=self:getAcVo()
	local leftNum=self:getLeftNum()
	if leftNum>0 and self:acIsStop()==false and activityVoApi:isStart(vo) then
		return true
	end
	return false
	-- local vo=self:getAcVo()
	-- if(vo==nil or vo.chips==nil or vo.chips<0)then
	-- 	return false
	-- else
	-- 	return true
	-- end
end

function acRoulette3VoApi:checkCanTenPlay()
	local vo=self:getAcVo()
	local leftNum=self:getLeftNum()
	if leftNum>=10 and self:acIsStop()==false and activityVoApi:isStart(vo) then
		return true
	end
	return false
end

-- function acRoulette3VoApi:getRewardList()
-- 	local vo=self:getAcVo()
-- 	if(vo==nil)then
-- 		return nil
-- 	else
-- 		return vo.rewardList
-- 	end
-- end

function acRoulette3VoApi:getRankList()
	local vo=self:getAcVo()
	if vo and vo.rankList and SizeOfTable(vo.rankList)>0 then
		return vo.rankList
	else
		return {}
	end
end

function acRoulette3VoApi:getSelfRank()
	local vo=self:getAcVo()
	if vo and vo.rankList and SizeOfTable(vo.rankList)>0 then
		for k,v in pairs(vo.rankList) do
			if v and v[1] and tostring(v[1])==tostring(playerVoApi:getPlayerName()) then
				return k
			end
		end
	end
	return "10+"
end

function acRoulette3VoApi:pointRewardUpdate(num)
	local vo=self:getAcVo()
	if vo and num then
		vo.pointRewardNum=num
		activityVoApi:updateShowState(vo)
	end
end

function acRoulette3VoApi:canReward()
	if acRoulette3VoApi:acIsStop()==false then
		return self:isFree()
		-- return self:checkCanPlay()
	end
	return false
end

function acRoulette3VoApi:isRouletteToday()
	local vo=self:getAcVo()
	if vo and vo.lastTime then
		if self.isToday~=G_isToday(vo.lastTime) and G_isToday(vo.lastTime)==false then	
			vo.consume=0
	        vo.hasUsedNum=0
	        vo.point=0
	        vo.hasUsedFreeNum=0
	        vo.pointRewardNum=0

        	self.isToday=false
        	self:setFlag(nil,0)

        	activityVoApi:updateShowState(vo)

        	return false
		end
	end
	return true
end

function acRoulette3VoApi:rankCanReward()
	local cfg=self:getRouletteCfg()
	local vo=self:getAcVo()
	if cfg and cfg.rankPoint and vo and vo.listRewardNum==0 and self:acIsStop()==true and activityVoApi:isStart(vo) then
		if vo.totalPoint and vo.totalPoint>=cfg.rankPoint then
			if vo.rankList and SizeOfTable(vo.rankList)>0 then
				for k,v in pairs(vo.rankList) do
					if v and v[1] and tostring(v[1])==tostring(playerVoApi:getPlayerName()) then
						return tonumber(k) or 0
					end
				end
			end
		end
	end
	return 0
end
function acRoulette3VoApi:setListRewardNum()
	local vo=self:getAcVo()
	if vo and vo.listRewardNum then
		vo.listRewardNum=1
		activityVoApi:updateShowState(vo)
	end
end

function acRoulette3VoApi:getIndexByNameAndType(name,type,num)
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

function acRoulette3VoApi:acIsStop()
	local vo=self:getAcVo()
	if vo and activityVoApi:isStart(vo) and base.serverTime<(vo.et-24*3600) then
		return false
	end
	return true
end
function acRoulette3VoApi:isEnd()
	local vo=self:getAcVo()
	if vo and base.serverTime<vo.et then
		return false
	end
	return true
end

