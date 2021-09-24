acSdzsVoApi={}

function acSdzsVoApi:getAcVo()
	if self.vo==nil then
		self.vo=activityVoApi:getActivityVo("sdzs")
	end
	return self.vo
end

function acSdzsVoApi:isToday()
	local isToday=false
	local vo=self:getAcVo()
	if vo and vo.t then
		isToday=G_isToday(vo.t)
	end
	return isToday
end

function acSdzsVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acSdzsVoApi:canReward()
	local vo=self:getAcVo()
	if vo==nil then
		return false
	end
	if self:isToday()==false then
		self:clearTaskData()
	end
	local timesCfg=self:getNeedTimes()
	for k,v in pairs(timesCfg) do
		local flag=self:checkIfReward(k)
		if flag==2 then
			return true
		end
	end
	return false
end

function acSdzsVoApi:afterGetReward(id)
	local acVo=self:getAcVo()
	if acVo then
		activityVoApi:updateShowState(acVo)
		acVo.stateChanged=true
	end
end

-- 自己当前的充值数
function acSdzsVoApi:getAttackNum()
	local vo=self:getAcVo()
	if vo and vo.v then
		return vo.v
	end
	return 0
end

function acSdzsVoApi:getNeedTimes()
	local vo=self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.needTimes then
		return vo.activeCfg.needTimes
	end
	return {}
end

function acSdzsVoApi:getRewardCfg()
	local vo=self:getAcVo()
	local rewardCfg={}
	if vo and vo.activeCfg and vo.activeCfg.reward then
		for k,v in pairs(vo.activeCfg.reward) do
			local rewardlist=FormatItem(v,nil,true)
			rewardCfg[k]=rewardlist
		end
	end
	return rewardCfg
end

function acSdzsVoApi:checkIfReward(id)
	local attackNum=self:getAttackNum()
	local needTimesCfg=self:getNeedTimes()
	local needTimes=needTimesCfg[id]
	local vo=self:getAcVo()
	if self:hasReward(id) then
		return 3
	elseif needTimes and tonumber(needTimes)<=attackNum then
		return 2
	end
	return 1
end

function acSdzsVoApi:hasReward(id)
	local vo=self:getAcVo()
	if vo and vo.r then
		for k,v in pairs(vo.r) do
			if tonumber(v)==tonumber(id) then
				return true
			end
		end
	end
	return false
end

function acSdzsVoApi:afterGetReward(id)
	local acVo=self:getAcVo()
	if acVo then
		activityVoApi:updateShowState(acVo)
		acVo.stateChanged=true
	end
end

function acSdzsVoApi:clearTaskData()
	local vo=self:getAcVo()
	if vo then
		vo.v=0
		vo.r={}
	end
end

function acSdzsVoApi:isAddFlicker(pkey)
	local vo=self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.flickReward then
		local flickReward=FormatItem(vo.activeCfg.flickReward,nil,true)
		for k,v in pairs(flickReward) do
			if v.key==pkey then
				return true
			end
		end
	end
	return false
end
-- function acSdzsVoApi:addActivieIcon()
-- 	spriteController:addPlist("public/activeCommonImage1.plist")
--     spriteController:addTexture("public/activeCommonImage1.png")
-- end

-- function acSdzsVoApi:removeActivieIcon()
-- 	spriteController:removePlist("public/activeCommonImage1.plist")
--     spriteController:removeTexture("public/activeCommonImage1.png")
-- end

function acSdzsVoApi:isEnd()
	local vo=self:getAcVo()
	if vo and base.serverTime<vo.et then
		return false
	end
	return true
end

function acSdzsVoApi:clearAll()
	self.vo=nil
end