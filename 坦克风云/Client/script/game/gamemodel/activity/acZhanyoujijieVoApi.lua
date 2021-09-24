--周年庆活动
acZhanyoujijieVoApi={
	lastChatTime=0,	--上一次发送聊天时间
	refreshFlag=0,	--是否刷新绑定玩家的充值列表
	initFlag=0,		--是否初始化rechargeInfo
	bdListFlag=0,	--绑定列表是否刷新
}

function acZhanyoujijieVoApi:getAcVo()
	return activityVoApi:getActivityVo("zhanyoujijie")
end

function acZhanyoujijieVoApi:getAcCfg()
	local acVo=self:getAcVo()
	if acVo and acVo.acCfg then
		return acVo.acCfg
	end
	return nil
end

function acZhanyoujijieVoApi:clearAll()
	self.lastChatTime=0
	self.refreshFlag=0
	self.initFlag=0
	self.bdListFlag=0
end

function acZhanyoujijieVoApi:canReward()
	local acVo=self:getAcVo()
	if(acVo==nil)then
		return false
	end
	return false
end

function acZhanyoujijieVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end

function acZhanyoujijieVoApi:getLastChatTime()
	return self.lastChatTime
end
function acZhanyoujijieVoApi:setLastChatTime(time)
	self.lastChatTime = time
end
function acZhanyoujijieVoApi:getRefreshFlag()
	return self.refreshFlag
end
function acZhanyoujijieVoApi:setRefreshFlag(refreshFlag)
	self.refreshFlag = refreshFlag
end
function acZhanyoujijieVoApi:getInitFlag()
	return self.initFlag
end
function acZhanyoujijieVoApi:setInitFlag(initFlag)
	self.initFlag = initFlag
end
function acZhanyoujijieVoApi:getBdListFlag()
	return self.bdListFlag
end
function acZhanyoujijieVoApi:setBdListFlag(bdListFlag)
	self.bdListFlag = bdListFlag
end

function acZhanyoujijieVoApi:isLevelLimit()
	local acCfg=self:getAcCfg()
	local vo=self:getAcVo()
	if acCfg and acCfg.limitLv and vo and vo.returnLv and vo.returnLv>=acCfg.limitLv then
		return false
	else
		return true
	end
end

function acZhanyoujijieVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acZhanyoujijieVoApi:getRechargeList(uid)
	local list={}
	local vo=self:getAcVo()
	if vo and vo.bindPlayers then
		for k,v in pairs(vo.bindPlayers) do
			if tonumber(uid)==tonumber(v.uid) and v.reList then
				list=G_clone(v.reList)
			end
		end
	end
	return list
end
function acZhanyoujijieVoApi:setRechargeList(uid,list)
	local vo=self:getAcVo()
	if list and SizeOfTable(list)>0 and vo and vo.bindPlayers and SizeOfTable(vo.bindPlayers)>0 then
		for k,v in pairs(vo.bindPlayers) do
			if tonumber(uid)==tonumber(v.uid) then
				vo.bindPlayers[k].reList=list
				local function sortFunc(a,b)
					if a and b and tonumber(a[2]) and tonumber(b[2]) then
						return tonumber(a[2])>tonumber(b[2])
					end
				end
				table.sort(vo.bindPlayers[k].reList,sortFunc)
			end
		end
	end
	activityVoApi:updateShowState(vo)
end

function acZhanyoujijieVoApi:canRewardState(uid,bindList)
	local isCan=false
	local canRewardNum=0
	if uid then
		local acVo=self:getAcVo()
	    local acCfg=self:getAcCfg()
	    if acCfg then
		    local bindPlayers
		    if bindList then
		    	bindPlayers=bindList
		    elseif acVo then
		    	bindPlayers=acVo.bindPlayers or {}
		    end
		    if bindPlayers then
			    for k,v in pairs(bindPlayers) do
			    	if v and tonumber(v.uid)==tonumber(uid) then
			    		local rechargeNum=0
			    		local reInfo=v
			    		if reInfo and reInfo.buyTotalNum then
					    	local hasRewardNum=reInfo.hasRewardNum or 0
					    	local rechargeNum=reInfo.buyTotalNum or 0
					    	if rechargeNum>acCfg.limitMoney then
						        rechargeNum=acCfg.limitMoney
						    end
						    local rechargeNum=math.floor(rechargeNum*acCfg.ratio)
						    if hasRewardNum<rechargeNum then
						    	canRewardNum=rechargeNum-hasRewardNum
						        isCan=true
						    end
						end
			    	end
			    end
			end
		end
	end
	return isCan,canRewardNum
end

function acZhanyoujijieVoApi:isShowRewardAll()
	local isShow,rewardNum=false,0
	local acVo=self:getAcVo()
    local acCfg=self:getAcCfg()
    if acVo and acCfg then
	    local playerList=acVo.bindPlayers or {}
	    if playerList then
		    for k,v in pairs(playerList) do
		    	local uid=v.uid
		    	local isCan,canRewardNum=self:canRewardState(uid)
		    	if isCan==true then
		    		rewardNum=rewardNum+canRewardNum
		    		isShow=true
		    	end
		    end
		end
	end
	return isShow,rewardNum
end

--流失玩家充值可以领取奖励的状态,0条件不足，1可以领取，2已经领取
function acZhanyoujijieVoApi:getStateByRechargeLv(i)
	local state=0
	local acVo=self:getAcVo()
    local acCfg=self:getAcCfg()
    if i and acVo and acCfg and acCfg.cost and acCfg.cost[i] then
	    local need=acCfg.cost[i]
	    if acVo.hasRewardTb and acVo.hasRewardTb[i]==1 then
	    	state=2
	    elseif acVo.buyGems and need and acVo.buyGems>=need then
	    	state=1
	    end
	end
 	return state
end
function acZhanyoujijieVoApi:getRechargePercent()
	local per=0
	local acVo=self:getAcVo()
    local acCfg=self:getAcCfg()
    if acVo and acVo.buyGems and acCfg and acCfg.cost then
    	local tmpCost=0
    	local costNum=SizeOfTable(acCfg.cost)
    	for k,v in pairs(acCfg.cost) do
    		if acVo.buyGems>v then
    			tmpCost=v
    			per=per+(1/costNum)
    		else
    			per=per+(acVo.buyGems-tmpCost)/(v-tmpCost)/costNum
    			break
    		end 
    	end
    end
    per=G_keepNumber((per*100),2)
    return per
end

function acZhanyoujijieVoApi:addBuyGems(addMoney)
	local acVo=self:getAcVo()
    if acVo and addMoney then
    	if acVo.buyGems==nil then
    		acVo.buyGems=0
    	end
    	acVo.buyGems=acVo.buyGems+addMoney
    end
end


function acZhanyoujijieVoApi:isShowRechargeList()
	local acVo=self:getAcVo()
	if acVo and acVo.bindPlayers and SizeOfTable(acVo.bindPlayers)>0 then
		for k,v in pairs(acVo.bindPlayers) do
			if v and v.buyTotalNum and v.buyTotalNum>0 then
				return true
			end
		end
	end
	return false
end

function acZhanyoujijieVoApi:updateRecharge(data,time)
	if data and SizeOfTable(data)>0 then
		local acCfg=self:getAcCfg()
		local acVo=self:getAcVo()
		if acVo and acVo.bindPlayers and SizeOfTable(acVo.bindPlayers)>0 then
			for m,n in pairs(data) do
				local uid=tonumber(m)
				local num=tonumber(n)
				for k,v in pairs(acVo.bindPlayers) do
					if uid and v.uid and uid==tonumber(v.uid) then
						if v.buyTotalNum==nil then
							v.buyTotalNum=0
						end
						local addNum=num-v.buyTotalNum
						if addNum and addNum>0 then
							if acCfg and acCfg.limitMoney and v.reList then
								local reItem={addNum,time}
								if num>=acCfg.limitMoney then
									local diffNum=num-acCfg.limitMoney
									table.insert(reItem,diffNum)
								end
								table.insert(v.reList,reItem)
								local function sortFunc(a,b)
									if a and b and tonumber(a[2]) and tonumber(b[2]) then
										return tonumber(a[2])>tonumber(b[2])
									end
								end
								table.sort(v.reList,sortFunc)
							end
						end
						v.buyTotalNum=num
					end
				end
			end
			activityVoApi:updateShowState(acVo)
			self:setRefreshFlag(1)
		end
	end
end


