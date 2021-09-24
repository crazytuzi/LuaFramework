acGrowingPlanVoApi={}

function acGrowingPlanVoApi:clearAll()

end

function acGrowingPlanVoApi:getAcVo()
	return activityVoApi:getActivityVo("growingPlan")
end

function acGrowingPlanVoApi:canReward()
	local vo = self:getAcVo()
	if playerVoApi:getIsBuyGrowingplan()~=nil and playerVoApi:getIsBuyGrowingplan()>0 then
		local growingPlanCfg = playerCfg.growingPlan
		for k,v in pairs(growingPlanCfg.playerLevelAndRewards) do
			if playerVoApi:getPlayerLevel()>=v.lv and playerVoApi:getGrowingPlanRewarded()<v.lv then
				return true
			end
		end
		
	end
	return false
end

function acGrowingPlanVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acGrowingPlanVoApi:updateShow()
    local vo=self:getAcVo()
    activityVoApi:updateShowState(vo)
end

