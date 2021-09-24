acLevelingVoApi = {}

function acLevelingVoApi:getAcVo()
	return activityVoApi:getActivityVo("leveling")
end

function acLevelingVoApi:getDesVate()
	local vo=self:getAcVo()
	if vo ~= nil and vo.desVate ~= nil then
		return vo.desVate
	end
	return 0
end
-- 指挥中心的当前等级
function acLevelingVoApi:getCurrentLev()
    local buildVo=buildingVoApi:getBuildiingVoByBId(1)
    if buildVo ~= nil then
	    return buildVo.level
	end
	return 0
end

function acLevelingVoApi:canReward()
	-- 第二重
	if self:checkIfCanReward(1) == true then
		return true
	end
    -- 第三重
	if self:checkIfCanReward(2) == true then
		return true
	end

	return false
end

function acLevelingVoApi:checkIfCanReward(num)
	local currentLv = self:getCurrentLev() -- 当前指挥中心的等级
	-- 第n重
	local needLv = self:getNeedLevel(num)
	if currentLv >= needLv and self:checkIfHadReward(num) == false then
		return true
	end
	return false
end

-- 是否已经获取该重奖励（num = 1 第二重， 2 第三重）
function acLevelingVoApi:checkIfHadReward(num)
	local vo=self:getAcVo()
	if vo ~= nil and vo.v ~= nil and type(vo.v) == "table" then
		local state = vo.v[num]
		if state ~= nil and tonumber(state) == 1 then
			return true
		end
	end
	return false
end

function acLevelingVoApi:getRewardCfgByLev(lv)
	local vo=self:getAcVo()
	if vo ~= nil and vo.reward ~= nil then
		for k,v in pairs(vo.reward) do
			if tonumber(RemoveFirstChar(k)) == lv then
				local reward1 = {u={}}
		        local rewardNum = v.num -- 可活动奖励个数
		        local i = 1
		        for k1,v1 in pairs(v.type) do
		            local tb = {index = i}
		            tb[v1] = rewardNum
		            table.insert(reward1.u, tb)
		            i = i + 1
		        end
				return k,v, reward1, rewardNum
			end
		end
	end
	return nil, nil,nil,0
end

function acLevelingVoApi:getNeedLevel(num)
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.condition ~= nil and num > 0 and num <= SizeOfTable(acVo.condition) then
        return acVo.condition[num]
	end
	return 99999
end

function acLevelingVoApi:afterGetReward()
	local acVo = self:getAcVo()
	if acVo ~= nil then
	    activityVoApi:updateShowState(acVo)	
	    acVo.stateChanged = true -- 强制更新数据	
	end
end

function acLevelingVoApi:tick()
	local vo=self:getAcVo()
	if vo ~= nil and self.isStart ~= activityVoApi:isStart(vo) then
		eventDispatcher:dispatchEvent("activity.levelingOpenOrClose")
		self.isStart = activityVoApi:isStart(vo)
	end
end
