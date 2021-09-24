acRechargeBagVoApi={
	rankList={},
	flag={},
	selfRank={rank=0,name="",value=0},
}

function acRechargeBagVoApi:getAcVo()
	if self.vo==nil then
		self.vo=activityVoApi:getActivityVo("rechargebag")
	end
	return self.vo
end

function acRechargeBagVoApi:updateData(data)
	local acVo=self:getAcVo()
	if acVo then
		acVo:updateSpecialData(data)
	end
end

function acRechargeBagVoApi:canReward()
	local flag=false
	local vo=self:getAcVo()
	if vo then
		local canRankReward=self:canRankReward()
		local extraCount=tonumber(vo.extraBag)-tonumber(vo.dl)
		if canRankReward==true then
			flag=true
		elseif extraCount>0 then
			flag=true
		else
			local cost=self:getRechargeLvCfg()
			for k,v in pairs(cost) do
				local state=self:getStateByRechargeLv(k)
				if state==2 then
					flag=true
					do break end
				end
			end
		end
	end

	return flag
end

function acRechargeBagVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end

function acRechargeBagVoApi:getTimeStr()
	local str=""
	local vo=self:getAcVo()
	if vo then
		local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt-86400)
		str=getlocal("activity_timeLabel")..":".."\n"..timeStr
	end

	return str
end

function acRechargeBagVoApi:getRewardTimeStr()
	local str=""
	local vo=self:getAcVo()
	if vo then
		local rewardTimeStr=activityVoApi:getActivityRewardTimeStr(vo.acEt-86400,60,86400)
		str=getlocal("recRewardTime")..":".."\n"..rewardTimeStr
	end
	return str
end

function acRechargeBagVoApi:isEnd()
	local vo=self:getAcVo()
	if vo and base.serverTime<vo.et then
		return false
	end
	return true
end

-- 是否是领奖时间
function acRechargeBagVoApi:acIsStop()
	local vo=self:getAcVo()
	if vo and base.serverTime<(vo.et-24*3600) then
		return false
	end
	return true
end

function acRechargeBagVoApi:getRechargeLvCfg()
	local vo=self:getAcVo()
	if vo then
		return vo.cost
	end
	return {}
end

function acRechargeBagVoApi:getBagByRechargeLv(lv)
	local bag={}
	local vo=self:getAcVo()
	if vo then
		if vo.reward and vo.reward[lv] then
			bag=vo.reward[lv]
		end
	end
	return bag
end

--获取各个充值等级的状态 1：还未达到 2：已达到 3：已领取
function acRechargeBagVoApi:getStateByRechargeLv(lv)
 	local state=1
 	local vo=self:getAcVo()
 	local rechargeLVCfg=self:getRechargeLvCfg()
 	if vo and vo.hasRewardTb and vo.gemsCount and rechargeLVCfg and rechargeLVCfg[lv] then
 		if tonumber(vo.gemsCount)<tonumber(rechargeLVCfg[lv]) then
 			state=1
		elseif self:hasRewarded(lv)==false then
			state=2
		else
 			state=3
 		end
 	end
 	return state
end

function acRechargeBagVoApi:hasRewarded(lv)
	local rewardFlag=false
 	local vo=self:getAcVo()
	if vo and vo.hasRewardTb then
		for k,v in pairs(vo.hasRewardTb) do
			if tonumber(v)==tonumber(lv) then
				rewardFlag=true
				do break end
			end
		end
	end
	return rewardFlag
end

function acRechargeBagVoApi:getRankReward()
	local reward={}
	local vo=self:getAcVo()
	if vo and vo.rankReward then
		reward=vo.rankReward
	end
	return reward
end

function acRechargeBagVoApi:getRechargeCount()
	local count=0
	local vo=self:getAcVo()
	if vo and vo.gemsCount then
		count=tonumber(vo.gemsCount)
	end
	return count
end

function acRechargeBagVoApi:getRechargePercent()
	local per=0
	local vo=self:getAcVo()
	if vo then
		local alreadyCost=self:getRechargeCount()
		local cost=self:getRechargeLvCfg()
		local numDuan=SizeOfTable(cost)
		if numDuan==0 then
			numDuan=4
		end
		local everyPer=100/numDuan
		local diDuan=0 
		for i=1,numDuan do
			if alreadyCost<=tonumber(cost[i]) then
				diDuan=i
				break
			end
		end

		if alreadyCost>=cost[numDuan] then
			per=100
		elseif diDuan==1 then
			per=alreadyCost/cost[1]/numDuan*100
		else
			per=(diDuan-1)*everyPer+(alreadyCost-cost[diDuan-1])/(cost[diDuan]-cost[diDuan-1])/numDuan*100
		end
	end
	return per	
end

function acRechargeBagVoApi:getRechargeLimit()
	local limit=0
	local vo=self:getAcVo()
	if vo and vo.limit then
		limit=tonumber(vo.limit)
	end
	return limit
end

function acRechargeBagVoApi:getNeedRecharge()
	local need=0
	local vo=self:getAcVo()
	if vo and vo.need then
		need=tonumber(vo.need)
	end
	return need
end

function acRechargeBagVoApi:getNeedPoint()
	local need=500
	local vo=self:getAcVo()
	if vo and vo.needPoint then
		need=tonumber(vo.needPoint)
	end
	return need
end

function acRechargeBagVoApi:getPoint()
	local point=5
	local vo=self:getAcVo()
	if vo and vo.point then
		point=tonumber(vo.point)
	end
	return point
end

--获取领取奖励的排名
function acRechargeBagVoApi:getNeedRank()
	return 10
end
--获取可以赠送的红包数量
function acRechargeBagVoApi:getDonateBag()
	local name,pic=getItem("p3306","p")
	local count=bagVoApi:getItemNumId(3306)
	return pic,count
end

function acRechargeBagVoApi:getExtraBag()
	local count=0
	local vo=self:getAcVo()
	if vo and vo.extra and vo.extraBag and vo.dl then
		count=tonumber(vo.extraBag)-tonumber(vo.dl)
		if count<0 then
			count=0
		end
		local extra=FormatItem(vo.extra)
		local icon,scale=G_getItemIcon(extra[1],80)
		local pid=extra[1].id
		return pid,icon,scale,count
	end
	return nil,nil,nil,nil
end

--获取额外充值的金币数
function acRechargeBagVoApi:getExtraCharge()
	local count=0
	local rechargeCount=self:getRechargeCount()
	local limit=self:getRechargeLimit()
	local need=self:getNeedRecharge()
	local vo=self:getAcVo()
	if vo and vo.dl then
		count=(rechargeCount-limit)-vo.dl*need
	end
	return count
end

function acRechargeBagVoApi:getGenerosity()
	local count=0
	local vo=self:getAcVo()
	if vo and vo.generosity then
		count=FormatNumber(vo.generosity)
	end

	return count
end

function acRechargeBagVoApi:updateData(data)
	local vo=self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
		activityVoApi:updateShowState(vo)
	end
end

function acRechargeBagVoApi:rechargeBagRequest(action,method,callback)
	local function rewardCallback(fn,data)
		local ret,sData=base:checkServerData(data)
        if ret==true then
            if sData and sData.data and sData.data.rechargebag then
            	self:updateData(sData.data.rechargebag)
            end
            if sData and sData.data and sData.data.reward then
            	local reward=sData.data.reward
            	local award=FormatItem(sData.data.reward) or {}
				for k,v in pairs(award) do
					G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
				end
				G_showRewardTip(award)
            end
            if callback then
            	callback()
            end
        end
    end

	if action=="ranklist" then --获取排行榜信息
		local function listCallback(fn,data)
			local ret,sData=base:checkServerData(data)
	        if ret==true then
	            if sData and sData.ranklist then
	            	local rank=sData.ranklist
	            	self:setRankList(rank)
	            	local uid=playerVoApi:getUid()
	            	local inRank=false
	            	for k,v in pairs(rank) do
	            		if uid==tonumber(v[1]) then
	            			self.selfRank.rank=k
	            			self.selfRank.name=v[2]
	            			self.selfRank.value=v[3]
	            			inRank=true
	            			do break end
	            		end
	            	end
	            	if inRank==false then
    					self.selfRank.rank=self:getNeedRank().."+"
            			self.selfRank.name=playerVoApi:getPlayerName()
            			self.selfRank.value=self:getGenerosity()
	            	end
	                if callback then
	                	callback()
	                end
	            end
	        end
	    end
		socketHelper:rechargebagRequest(action,nil,nil,listCallback)
	elseif action=="rankreward" then --领取排行榜奖励
		local canReward,status,rank=self:canRankReward()
		if canReward==true and rank and rank>0 then
			socketHelper:rechargebagRequest(action,nil,rank,rewardCallback)
		end
	elseif action=="reward" then  --领取对应充值额度的奖励
		local state=self:getStateByRechargeLv(method)
		if state==2 then
			socketHelper:rechargebagRequest(action,method,nil,rewardCallback)
		end
	elseif action=="extra" then  --领取对应充值额度的奖励
		socketHelper:rechargebagRequest(action,nil,nil,rewardCallback)
	end
end

function acRechargeBagVoApi:getRankList()
	if self.rankList then
		return self.rankList
	else
		return {}
	end
end

function acRechargeBagVoApi:setRankList(rank)
	if rank then
		if self.rankList==nil then
			self.rankList={}
		end
		self.rankList=rank
	end
end

function acRechargeBagVoApi:getSelfRank()
	return self.selfRank
end

function acRechargeBagVoApi:canRankReward()
	if self and self:acIsStop()==true then
		local rankList=self:getRankList()
		if rankList and SizeOfTable(rankList)>0 then
			for k,v in pairs(rankList) do
				if v and v[1] and tonumber(v[1])==playerVoApi:getUid() then
					local vo=self:getAcVo()
					if vo and vo.rankRwardFlag and vo.rankRwardFlag==1 then
						return false,2
					end
					return true,0,k
				end
			end
		end
	end
	return false,1
end

function acRechargeBagVoApi:getFlag(idx)
	if SizeOfTable(self.flag)==0 then
		return -1
	elseif idx and self.flag[idx] then
		return self.flag[idx]
	else
		return -1
	end
end
function acRechargeBagVoApi:setFlag(idx,flag)
	self.flag[idx]=flag
end
function acRechargeBagVoApi:setAllFlag()
    for i=1,2 do
        self.flag[i]=0
    end
end

function acRechargeBagVoApi:tick()
	if self:acIsStop()==false then

	end
end

function acRechargeBagVoApi:clearAll()
	self.rankList={}
	self.flag={}
	self.selfRank={rank=0,name="",value=0}
	self.vo=nil
end