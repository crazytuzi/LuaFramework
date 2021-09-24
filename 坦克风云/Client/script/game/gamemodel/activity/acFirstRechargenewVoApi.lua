acFirstRechargenewVoApi = {}

function acFirstRechargenewVoApi:getAcVo()
	return activityVoApi:getActivityVo("firstRechargenew")
end

function acFirstRechargenewVoApi:getAcCfg()
	local acVo = self:getAcVo()
	if acVo.reward then
		if base.heroSwitch==1 then
			return acVo.reward.hero
		else
			return acVo.reward.nohero
		end
	end
	return {}
end

function acFirstRechargenewVoApi:canReward()
	local vo = self:getAcVo()
    -- print("ddddddddddd=",type(vo.c),vo.c,type(vo.v),vo.v)
	-- if vo.c ~= nil and vo.v ~= nil and vo.c >= vo.v then
	if vo.c ~= nil and vo.c > 0 then
		return true
	end
	return false
end


