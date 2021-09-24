acRamadanVoApi={}

function acRamadanVoApi:getAcVo()
	if self.vo==nil then
		self.vo=activityVoApi:getActivityVo("ramadan")
	end
	return self.vo
end

function acRamadanVoApi:getVersion()
	local vo=self:getAcVo()
	if vo and vo.activeCfg then
		return vo.activeCfg.version or 1
	end
	return 1 --默认
end

function acRamadanVoApi:getTimeStr()
	local str=""
	local vo=self:getAcVo()
	if vo then
		local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
		str=getlocal("activity_timeLabel")..":".."\n"..timeStr
	end

	return str
end

function acRamadanVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acRamadanVoApi:isToday()
	local isToday=false
	local vo=self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acRamadanVoApi:canReward()
	local vo=self:getAcVo()
	if vo==nil then
		return false
	end
	local rdata=self:getRewardsState()
	for k,r in pairs(rdata) do
		if tonumber(r)>0 then
			return true
		end
	end
	return false
end

--各礼包的奖励数据
function acRamadanVoApi:getRewards()
	local acVo=self:getAcVo()
	if acVo and acVo.activeCfg then
		local reward1=FormatItem(acVo.activeCfg.reward1)
		local reward2=FormatItem(acVo.activeCfg.reward2)
		local reward3=FormatItem(acVo.activeCfg.reward3)
		return {reward1[1],reward2[1],reward3[1]}
	end
	return {}
end

--礼包领取的数据
function acRamadanVoApi:getRewardsState()
	local acVo=self:getAcVo()
	if acVo then
		return {acVo.r1,acVo.r2,acVo.r3}
	end
	return {}
end

function acRamadanVoApi:getRecharge()
	local acVo=self:getAcVo()
	if acVo and acVo.v then
		return acVo.v or 0
	end
	return 0
end

function acRamadanVoApi:getRechargeCfg()
	local acVo=self:getAcVo()
	if acVo and acVo.activeCfg then
		return acVo.activeCfg.recharge1,acVo.activeCfg.recharge2
	end
	return 0,0
end

--是否使用带斋月活动的充值档位
function acRamadanVoApi:isUseNewStoreCfg()
	local acVo=self:getAcVo()
	if acVo and activityVoApi:isStart(acVo)==true and ((G_curPlatName()=="androidarab" and G_Version>=15) or (G_curPlatName()=="21" and G_Version>=15) or (G_curPlatName()=="0")) then
		return true
	end
	return false
end

function acRamadanVoApi:isEnd()
	local vo=self:getAcVo()
	if vo and base.serverTime<vo.et then
		return false
	end
	return true
end

function acRamadanVoApi:clearAll()
	self.vo=nil
end
