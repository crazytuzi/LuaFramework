acHeartOfIronVoApi = {
	dayFlag=0,
}

function acHeartOfIronVoApi:clearAll()
	self.dayFlag=0
end

function acHeartOfIronVoApi:getFlag()
	return self.dayFlag
end
function acHeartOfIronVoApi:setFlag(flag)
	self.dayFlag=flag
end

function acHeartOfIronVoApi:getAcVo()
	return activityVoApi:getActivityVo("heartOfIron")
end

function acHeartOfIronVoApi:getAcCfg()
	return activityCfg["heartOfIron"]
end

--获取当前是注册后哪一天(第1，2天都算第一天)
function acHeartOfIronVoApi:getDays()
	local regdate=playerVoApi:getRegdate()
	local regZeroTs=G_getWeeTs(regdate)
	local dayNum=math.ceil((base.serverTime-regZeroTs)/(3600*24))-1
	if dayNum<1 then
		dayNum=1
	end
	return dayNum
end

--当前状态：0 已结束，1 正在进行，2 还未开启
function acHeartOfIronVoApi:getStatus(index)
	local currentDay=self:getDays()
	if index<currentDay then
		return 0
	elseif index==currentDay then
		return 1
	elseif index>currentDay then
		return 2
	end
end

--是否已完成
function acHeartOfIronVoApi:isComplete(key)
	local vo=self:getAcVo()
	if vo.taskTab then
		for k,v in pairs(vo.taskTab) do
			if v.type==key then
				local cfgNum=v.cfgNum
				local num=v.num
				if cfgNum>0 and num>=cfgNum then
					return true
				end
			end
		end
	end
	return false
end

--是否能领取
function acHeartOfIronVoApi:canRewardByIndex(index,key)
	local status=self:getStatus(index)
	local isComplete=self:isComplete(key)
	local hadReward=self:hadReward(key)
	if (status==0 or status==1) and isComplete==true and hadReward==false then
		return true
	end
	return false
end

function acHeartOfIronVoApi:hadReward(key)
	local vo=self:getAcVo()
	if vo.taskTab then
		for k,v in pairs(vo.taskTab) do
			if v.type==key then
				if v.isReward==1 then
					return true
				end
			end
		end
	end
	return false
end
--设置已领取
function acHeartOfIronVoApi:setHadReward(key)
	local vo=self:getAcVo()
	if vo.taskTab then
		for k,v in pairs(vo.taskTab) do
			if v.type==key then
				vo.taskTab[k].isReward=1
			end
		end
	end
	activityVoApi:updateShowState(vo)
end

function acHeartOfIronVoApi:updateNum(key,addNum)
	local vo=self:getAcVo()
	
	if vo and vo.taskTab then
		for k,v in pairs(vo.taskTab) do
			local keyType
			local isUpdate=false
			local status=self:getStatus(k)
			if status==1 then
				if key==nil then
					keyType=v.type
					isUpdate=true
				elseif key==v.type then
					keyType=key
					isUpdate=true
				end
			end
			if isUpdate==true then
				if keyType=="blevel" then		--指挥中心升到10级
					local bid=1
					local buildVo=buildingVoApi:getBuildiingVoByBId(bid)
					if buildVo.status>0 then
						v.num=buildVo.level
					end
				elseif keyType=="ulevel" then	--角色等级升到10级
					v.num=playerVoApi:getPlayerLevel()
				elseif keyType=="alevel" then	--将任意配件强化到5级
					local accessoryMaxLevel=accessoryVoApi:getAccessoryMaxLevel()
					if v.num<accessoryMaxLevel then
						v.num=accessoryMaxLevel
					end
				elseif keyType=="acrd" then		--领取5个军团副本中击杀敌军获得的“军需宝箱”
					if addNum then
						v.num=v.num+addNum
					end
				elseif keyType=="star" then		--关卡副本获得100个星数
					v.num=checkPointVoApi:getStarNum()
				elseif keyType=="tech" then		--在“科研中心”将任意科技升到10级
					local techMaxLevel=technologyVoApi:getMaxLevel()
					if v.num<techMaxLevel then
						v.num=techMaxLevel
					end
				elseif keyType=="troops" then	--生产任意“重型”部队100辆
				end
			end
		end
	end
end

function acHeartOfIronVoApi:currentCanReward()
	local currentCanReward=false
	local vo=self:getAcVo()
	if vo and vo.taskTab then
		for k,v in pairs(vo.taskTab) do
			currentCanReward=self:canRewardByIndex(k,v.type)
			if currentCanReward==true then
				return true
			end
		end
	end
	return false
end

function acHeartOfIronVoApi:canReward()
	local flag=acHeartOfIronVoApi:getFlag()
	local lastLoginTime=playerVoApi:getLogindate()
	local isToday=G_isToday(lastLoginTime)
	self:updateNum()
	if (isToday==false and flag==0) or self:currentCanReward()==true then
		return true
	else
		return false
	end
end

function acHeartOfIronVoApi:isEnd()
	local vo=self:getAcVo()
    if vo and tonumber(vo.st) <= tonumber(base.serverTime) and tonumber(base.serverTime) < tonumber(vo.et) then
    	if vo.changeday and vo.changeday>0 then
    		local dayNum=self:getDays()
			if dayNum>vo.changeday then
				self.over=true
    			return true
    		end
    	end
    end
    return false
end

function acHeartOfIronVoApi:getCountdownStr()
	local countNum=G_getWeeTs(base.serverTime)+(24*3600)-base.serverTime
	if G_getWeeTs(base.serverTime)==G_getWeeTs(playerVoApi:getRegdate()) then
		countNum=countNum+(3600*24)
	end
	if countNum<0 then
		countNum=0
	end
	local countStr=G_getTimeStr(countNum)
    return countStr
end

