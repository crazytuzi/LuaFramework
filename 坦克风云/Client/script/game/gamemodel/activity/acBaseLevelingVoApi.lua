acBaseLevelingVoApi = {}

function acBaseLevelingVoApi:getAcVo()
	return activityVoApi:getActivityVo("baseLeveling")
end

function acBaseLevelingVoApi:getAcCfg()
    local vo=self:getAcVo()
	return vo.cfg
end

-- 活动排名名次最终确定的时间等领奖条件最终确定不变的时间
function acBaseLevelingVoApi:getEndTime()
    local acVo = self:getAcVo()
    if acVo ~= nil then
    	return acVo.acEt
    end
    return 0
end

function acBaseLevelingVoApi:canReward()
	local cfg = self:getAcCfg()
	if(cfg==nil)then
		return false
	end
	local len = SizeOfTable(cfg)
	for i=1,len do
		if self:checkIfCanRewardById(i) == true and self:checkIfHadRewardById(i) == false then
			return true
		end
	end
	return false
end

function acBaseLevelingVoApi:getRewardById(id)
	local acCfg = self:getAcCfg()
	if acCfg ~= nil then
		if acCfg[id] ~= nil then
			return acCfg[id].award
		end
	end
	return nil
end


function acBaseLevelingVoApi:getNeedCenterLevById(id)
	local acCfg = self:getAcCfg()
	if acCfg ~= nil then
		local cfg = acCfg[id]
		if cfg ~= nil then
			return tonumber(cfg.lv)
		end
	end
	return nil
end

function acBaseLevelingVoApi:checkIfHadRewardById(id)
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.t ~= nil and type(acVo.t) == "table" then
		for k,v in pairs(acVo.t) do
			if v == self:getNeedCenterLevById(id) then
				return true
			end
		end
	end
	return false
end

function acBaseLevelingVoApi:getBaseLevel()
	local acVo = self:getAcVo()
	local lev = 0 -- buildVo.level -- 当前指挥中心的等级
	if acVo ~= nil and acVo.c > 0 then
		lev = acVo.c
	end
	return lev
end

function acBaseLevelingVoApi:checkIfCanRewardById(id)
	local needLev = self:getNeedCenterLevById(id) -- 需要的指挥中心的等级
	local lev = self:getBaseLevel()
	if needLev ~= nil and lev >= needLev then
		return true
	end
	return false
end

function acBaseLevelingVoApi:afterGetReward(id)
	local acVo = self:getAcVo()
	if acVo ~= nil then
		if acVo.t == nil or type(acVo.t) ~= "table"  then
             acVo.t = {}
		end
		table.insert(acVo.t, self:getNeedCenterLevById(id))
	end
	activityVoApi:updateShowState(acVo)
end

function acBaseLevelingVoApi:UpgradeSuccess()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		acVo.c = acVo.c + 1
	end
	activityVoApi:updateShowState(acVo)
	acVo.stateChanged = true -- 强制更新数据
end
