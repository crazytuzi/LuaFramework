
acMonsterComebackVoApi={}

function acMonsterComebackVoApi:getAcVo()
	return activityVoApi:getActivityVo("monsterComeback")
end

function acMonsterComebackVoApi:getAcCfg()
	-- return activityCfg["monsterComeback"]
	if activityCfg["monsterComeback"][G_curPlatName()]~=nil then
          return activityCfg["monsterComeback"][G_curPlatName()]
    else
          return activityCfg["monsterComeback"]["raycommon"] 
    end
end

function acMonsterComebackVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end


function acMonsterComebackVoApi:setTankPartNum(type,num)
	local vo = self:getAcVo()
	if type==1 then
		vo.rart1Num=num
	elseif type==2 then
		vo.rart2Num=num
	end
	activityVoApi:updateShowState(vo)
end

function acMonsterComebackVoApi:setLastTime(time)
	local vo = self:getAcVo()
	vo.lastTime=time
	activityVoApi:updateShowState(vo)
end

function acMonsterComebackVoApi:setPoint(point)
	local vo = self:getAcVo()
	if vo and vo.point and point then
		vo.point=point
	end
	activityVoApi:updateShowState(vo)
end

function acMonsterComebackVoApi:canReward()
	local cfg=acMonsterComebackVoApi:getAcCfg()
	local pointCost=cfg.serverreward.pointCost
	local upgradePartConsume=cfg.serverreward.upgradePartConsume
	local vo = self:getAcVo()
	local isCanReward=false
	if vo and activityVoApi:isStart(vo)==true then
		if (self:isToday()==false) or (vo.point and vo.point>=pointCost) or (vo.rart1Num and vo.rart1Num>=upgradePartConsume) or (vo.rart2Num and vo.rart2Num>=upgradePartConsume) then
			isCanReward=true
		end
	end
	return isCanReward
end


