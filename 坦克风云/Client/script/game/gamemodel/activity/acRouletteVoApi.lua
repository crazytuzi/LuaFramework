acRouletteVoApi = {
	flag={0,0,0},
	isToday=true,
	lastListTime=0,
}

function acRouletteVoApi:clearAll()
	self.flag={0,0,0}
	self.isToday=true
	self.lastListTime=0
end

function acRouletteVoApi:getAcVo()
	return activityVoApi:getActivityVo("wheelFortune")
end

function acRouletteVoApi:clearRankList()
	local data={rankList={}}
	local vo=self:getAcVo()
	vo:updateSpecialData(data)
end
function acRouletteVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acRouletteVoApi:getVersion( )
	local vo = self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1
end

function acRouletteVoApi:getRouletteCfg()
	local vo = self:getAcVo()
	if vo and vo.cfg then
		return vo.cfg
	end
	return {} 
end

function acRouletteVoApi:getFlag(idx)
	return self.flag[idx]
end
function acRouletteVoApi:setFlag(idx,value)
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

function acRouletteVoApi:getLastListTime()
	return self.lastListTime
end
function acRouletteVoApi:setLastListTime(time)
	self.lastListTime=time
end

function acRouletteVoApi:getCostRewardNum()
	local num = 0
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
function acRouletteVoApi:getUsedNum()
	local vo=self:getAcVo()
	local usedNum=0
	if vo and vo.hasUsedFreeNum and vo.hasUsedNum then
		usedNum=vo.hasUsedFreeNum+vo.hasUsedNum
	end
	return usedNum
end
function acRouletteVoApi:getLeftNum()
	local totleNum=self:getCostRewardNum()
	local vo=self:getAcVo()
	local leftNum=0
	local freeNum=0
	if acRouletteVoApi:acIsStop()==false then 
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

function acRouletteVoApi:checkCanPlay()
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

-- function acRouletteVoApi:getRewardList()
-- 	local vo=self:getAcVo()
-- 	if(vo==nil)then
-- 		return nil
-- 	else
-- 		return vo.rewardList
-- 	end
-- end

function acRouletteVoApi:getRankList()
	local vo=self:getAcVo()
	if vo and vo.rankList and SizeOfTable(vo.rankList)>0 then
		return vo.rankList
	else
		return {}
	end
end

function acRouletteVoApi:getSelfRank()
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

function acRouletteVoApi:pointRewardUpdate(num)
	local vo=self:getAcVo()
	if vo and num then
		vo.pointRewardNum=num
		activityVoApi:updateShowState(vo)
	end
end

function acRouletteVoApi:canReward()
	if acRouletteVoApi:acIsStop()==false then
		return self:checkCanPlay()
	-- else
	-- 	if self:rankCanReward()>0 then
	-- 		return true
	-- 	else
	-- 		return false
	-- 	end
	end
	return false
end

function acRouletteVoApi:isRouletteToday()
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

function acRouletteVoApi:rankCanReward()
	local cfg=self:getRouletteCfg()
	local vo=self:getAcVo()
	if vo and vo.listRewardNum==0 and self:acIsStop()==true and activityVoApi:isStart(vo) then
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
function acRouletteVoApi:setListRewardNum()
	local vo=self:getAcVo()
	if vo and vo.listRewardNum then
		vo.listRewardNum=1
		activityVoApi:updateShowState(vo)
	end
end
function acRouletteVoApi:acIsStop()
	local vo=self:getAcVo()
	if vo and base.serverTime<(vo.et-24*3600) then
		return false
	end
	return true
end
function acRouletteVoApi:isEnd()
	local vo=self:getAcVo()
	if vo and base.serverTime<vo.et then
		return false
	end
	return true
end

