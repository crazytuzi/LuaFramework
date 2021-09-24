acCustomRechargeRebateVoApi = {}

function acCustomRechargeRebateVoApi:getAcVo()
	return activityVoApi:getActivityVo("customRechargeRebate")
end

function acCustomRechargeRebateVoApi:getDiscount()
	local vo = self:getAcVo()
	if vo and vo.discount then
		return vo.discount
	end
	return 0
end

function acCustomRechargeRebateVoApi:canReward()
	return false
end

-- function acCustomRechargeRebateVoApi:updateRecharge()
-- 	local vo = self:getAcVo()
-- 	vo.over=false
-- 	activityVoApi:updateShowState(vo)
-- end


