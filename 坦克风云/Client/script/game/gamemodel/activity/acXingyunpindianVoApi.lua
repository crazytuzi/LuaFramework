acXingyunpindianVoApi={}

-- 这里需要修改
function acXingyunpindianVoApi:getAcVo()
	return activityVoApi:getActivityVo("xingyunpindian")
end

function acXingyunpindianVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end

function acXingyunpindianVoApi:getRouletteCfg()
	local vo=self:getAcVo()
	if vo and vo.acCfg then
		return vo.acCfg
	end
	return {}
end

function acXingyunpindianVoApi:getflickerPosition()
	local vo=self:getAcVo()
	if vo and vo.position then
		if vo.position==0 then
			vo.position=1
		end
		return vo.position
	end
	return 1
end

function acXingyunpindianVoApi:setflickerPosition(pos)
	local vo=self:getAcVo()
	if vo and vo.position then
		vo.position=pos
	end
end

function acXingyunpindianVoApi:getDiceNum()
	return 6,6
end

function acXingyunpindianVoApi:getAlreadyCost()
	local vo=self:getAcVo()
	if vo and vo.alreadyCost then
		return vo.alreadyCost
	end
	return 0
end

function acXingyunpindianVoApi:getAlreadyUse()
	local vo=self:getAcVo()
	if vo and vo.alreadyUse then
		return vo.alreadyUse
	end
	return 0
end

function acXingyunpindianVoApi:getRecharge()
	local vo=self:getAcVo()
	if vo and vo.recharge then
		return vo.recharge
	end
	return 100000
end

function acXingyunpindianVoApi:getNowNum()
	local alreadyCost=self:getAlreadyCost()
	local alreadyUse=self:getAlreadyUse()
	local recharge=self:getRecharge()
	return math.floor(alreadyCost/recharge-alreadyUse)
end

function acXingyunpindianVoApi:updateData(data)
	local vo=self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
	end
end

function acXingyunpindianVoApi:ChangeAlreadyCost(addMoney)
	local vo=self:getAcVo()
	if vo.alreadyCost==nil then
		vo.alreadyCost=0
	end
	vo.alreadyCost=vo.alreadyCost+addMoney
end

function acXingyunpindianVoApi:getMul()
	local vo=self:getAcVo()
	if vo and vo.multiCost then
		return vo.multiCost
	end
	return 10
end


function acXingyunpindianVoApi:canReward()
	local isfree=false	
	local nowNum = self:getNowNum()
	if 	nowNum>0 then
		isfree=true
	end
	return isfree
end