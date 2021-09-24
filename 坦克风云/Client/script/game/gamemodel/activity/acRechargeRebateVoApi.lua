acRechargeRebateVoApi = {}

function acRechargeRebateVoApi:getAcVo()
	return activityVoApi:getActivityVo("rechargeRebate")
end

function acRechargeRebateVoApi:getDiscount()
	local vo = self:getAcVo()
	if vo and vo.discount then
		return vo.discount
	end
	return activityCfg.rechargeRebate.discount
end

function acRechargeRebateVoApi:canReward()
    -- if G_curPlatName()=="androidjapan" or G_curPlatName()=="20" or G_curPlatName()=="31" or G_curPlatName()=="0" then
    --     return false
    -- else
        local vo = self:getAcVo()
        if activityVoApi:isStart(vo)==true and vo.c ~= nil and vo.c>0 then
            return true
        end
    -- end
	return false
end

-- function acRechargeRebateVoApi:updateData(data)
-- 	local vo=self:getAcVo()
-- 	vo:updateData(data)
-- 	activityVoApi:updateShowState(vo)
-- end

function acRechargeRebateVoApi:updateRecharge()
	local vo = self:getAcVo()
	vo.c=-1
	activityVoApi:updateShowState(vo)
end

--获取倒计时方法，无领奖时间
function acRechargeRebateVoApi:getTimeStr( ... )
	local str=""
	local vo=self:getAcVo()
	if vo then
		local activeTime = vo.et - base.serverTime > 0 and G_formatActiveDate(vo.et  - base.serverTime) or nil
		if activeTime==nil then
			activeTime=getlocal("serverwarteam_all_end")
		end
		return activeTime
	end
	return str
end
function acRechargeRebateVoApi:updateRechargeNum(num)
	local vo = self:getAcVo()
	if activityVoApi:isStart(vo)==true and base.serverTime<(vo.et-24*3600) then
		vo.c=num
		activityVoApi:updateShowState(vo)
	end
end

