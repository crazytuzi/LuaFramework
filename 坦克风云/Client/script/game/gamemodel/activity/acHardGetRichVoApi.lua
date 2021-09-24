acHardGetRichVoApi = {
	resRankTb={},
	nameRankTb={},
}	

function acHardGetRichVoApi:clearAll()

end

function acHardGetRichVoApi:getAcVo()
	return activityVoApi:getActivityVo("hardGetRich")
end

function acHardGetRichVoApi:setResRank(tb)
	self:getAcVo().res=tb
end
function acHardGetRichVoApi:initResRank(key,tb)
	self.resRankTb[key]={}
	self.resRankTb[key]=tb
end

function acHardGetRichVoApi:initNameRank(tb)
	self.nameRankTb={}
	self.nameRankTb=tb
end

function acHardGetRichVoApi:getResRankByKey(key)
	return self.resRankTb[key]
end

function acHardGetRichVoApi:getNameRank()
	return self.nameRankTb
end

function acHardGetRichVoApi:getSelfRankByKey(key)
	local rank="30+"
	for k,v in pairs(self.resRankTb[key]) do
		if playerVoApi:getPlayerName()== v[1] then
			rank=k
			break
		end
	end
	return rank
end

function acHardGetRichVoApi:getResTb()
	local resTb={gold=0,r1=0,r2=0,r3=0,r4=0}
	local keyTb={"gold","r1","r2","r3","r4"}
	if self:getAcVo().res==0 then
		resTb={gold=0,r1=0,r2=0,r3=0,r4=0}
	else
		for k,v in pairs(keyTb) do
			if self:getAcVo().res~=nil and self:getAcVo().res[v]~=nil then
				resTb[v]=self:getAcVo().res[v]
			end
		end
	end

	return resTb
end
function acHardGetRichVoApi:getPersonreward()
	return self:getAcVo().personreward
end
function acHardGetRichVoApi:setIsReward(key,method)
    if self:getAcVo().pReward==nil or self:getAcVo().pReward==0 then
        self:getAcVo().pReward={}
    end
	if self:getAcVo().pReward[key]==nil then
		self:getAcVo().pReward[key]={}
	end
	table.insert(self:getAcVo().pReward[key],method)

	
end

function acHardGetRichVoApi:setIsRewardR(key)
	local isin=false
	if self:getAcVo().rReward==nil then
		self:getAcVo().rReward={}
	end
	for k,v in pairs(self:getAcVo().rReward) do
		if key==v then
			isin=true
		end
	end
	if isin==false then
		table.insert(self:getAcVo().rReward,key)
	end
	
end
function acHardGetRichVoApi:getIsRewardRByKey(key)
	local isin=false
	if self:getAcVo().rReward~=nil then
		for k,v in pairs(self:getAcVo().rReward) do
			if key==v then
				isin=true
			end
		end
	end
	return isin
end

function acHardGetRichVoApi:getPersonGoalByKey(key)
	local tb={gold={0,0,0,0},r1={0,0,0,0},r2={0,0,0,0},r3={0,0,0,0},r4={0,0,0,0}}
	local goal=0

	for i=1,4,1 do
		if self:getResTb()[key]>=activityCfg.hardGetRich.personalGoal[i] then
			goal=i
		end
	end
	if self:getAcVo().pReward~=nil and self:getAcVo().pReward~=0 and self:getAcVo().pReward[key]~=nil then
		for k,v in pairs(self:getAcVo().pReward[key]) do
			tb[key][v]=1
		end
		
	end
	return goal,tb[key]
end
function acHardGetRichVoApi:getRankReward()
	return self:getAcVo().rankreward
end


function acHardGetRichVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acHardGetRichVoApi:updateShow()
    local vo=self:getAcVo()
    activityVoApi:updateShowState(vo)
end

function acHardGetRichVoApi:isCanRewardRank(key)
	local iscan=false
	
	if base.serverTime<self:getAcVo().et and base.serverTime>self:getAcVo().acEt and tostring(acHardGetRichVoApi:getSelfRankByKey(key))~="30+" then
		iscan=true
	end
	local vo=self:getAcVo()
	if vo.rReward~=nil then
		for k,v in pairs(vo.rReward) do
		 	if key==v then
		 		iscan=false
		 	end
		 end 
	end

	return iscan
end

function acHardGetRichVoApi:canReward()

	local canR=false
	local tb={"gold","r1","r2","r3","r4"}
	for k,v in pairs(tb) do
		local goal,goalTb= self:getPersonGoalByKey(v)
		for kk,vv in pairs(goalTb) do
			if goal and kk<=goal and vv==0 then
				canR=true
				break
			end
		end
	end	
    return canR
end
function acHardGetRichVoApi:isTodayReceive()

end

function acHardGetRichVoApi:getRouletteCfg()
	return activityCfg.wheelFortune.serverreward
end

function acHardGetRichVoApi:getFlag(idx)
	return self.flag[idx]
end
function acHardGetRichVoApi:setFlag(idx,value)
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

function acHardGetRichVoApi:getLastListTime()
	return self.lastListTime
end
function acHardGetRichVoApi:setLastListTime(time)
	self.lastListTime=time
end

function acHardGetRichVoApi:getCostRewardNum()
	local cfg=self:getRouletteCfg()
	local vo=self:getAcVo()
	local consume=0
	if vo and vo.consume then
		consume=vo.consume
	end
	local num=math.floor(consume/cfg.lotteryConsume)
	return num
end
function acHardGetRichVoApi:getUsedNum()
	local vo=self:getAcVo()
	local usedNum=0
	if vo and vo.hasUsedFreeNum and vo.hasUsedNum then
		usedNum=vo.hasUsedFreeNum+vo.hasUsedNum
	end
	return usedNum
end
function acHardGetRichVoApi:getLeftNum()
	local totleNum=self:getCostRewardNum()
	local vo=self:getAcVo()
	local leftNum=0
	local freeNum=0
	if acHardGetRichVoApi:acIsStop()==false then 
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

function acHardGetRichVoApi:checkCanPlay()
	local vo=self:getAcVo()
	local leftNum=self:getLeftNum()
	if leftNum>0 and self:acIsStop()==false and activityVoApi:isStart(vo) then
		return true
	end
	return false
end

function acHardGetRichVoApi:pointRewardUpdate(num)
	local vo=self:getAcVo()
	if vo and num then
		vo.pointRewardNum=num
		activityVoApi:updateShowState(vo)
	end
end


function acHardGetRichVoApi:isRouletteToday()
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


function acHardGetRichVoApi:acIsStop()
	local vo=self:getAcVo()
	if vo and base.serverTime<(vo.et-24*3600) then
		return false
	end
	return true
end
function acHardGetRichVoApi:isEnd()
	local vo=self:getAcVo()
	if vo and base.serverTime<vo.et then
		return false
	end
	return true
end

