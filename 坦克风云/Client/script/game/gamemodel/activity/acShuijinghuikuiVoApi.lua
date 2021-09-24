acShuijinghuikuiVoApi={}

function acShuijinghuikuiVoApi:getAcVo()
	return activityVoApi:getActivityVo("shuijinghuikui")
end

function acShuijinghuikuiVoApi:updateShow()
    local vo=self:getAcVo()
    activityVoApi:updateShowState(vo)
end

function acShuijinghuikuiVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end

function acShuijinghuikuiVoApi:getGemsVate()
	local vo = self:getAcVo()
	if vo and vo.gemsVate then
		return vo.gemsVate
	end
	return 0
end

function acShuijinghuikuiVoApi:getDailyGold()
	local vo = self:getAcVo()
	if vo and vo.dailyGold then
		return vo.dailyGold
	end
	return 0
end


function acShuijinghuikuiVoApi:getAllRechargeNum()
	local vo = self:getAcVo()
	if vo and vo.rechargeNum then
		return vo.rechargeNum
	end
	return 0
end
function acShuijinghuikuiVoApi:addAllRechargeNum(add)
	local vo = self:getAcVo()
	if vo then
		if vo.rechargeNum == nil then
			vo.rechargeNum = 0
		end
		vo.rechargeNum = vo.rechargeNum + add
	end
end

function acShuijinghuikuiVoApi:setAllRechargeNum(num)
	local vo = self:getAcVo()
	if vo then
		vo.rechargeNum = num
	end
end

function acShuijinghuikuiVoApi:getDailyRechargeNum()
	local vo = self:getAcVo()
	if vo and vo.dailyRecharge then
		return vo.dailyRecharge
	end
	return 0
end

function acShuijinghuikuiVoApi:refreshDailyRechargeNum()
	local vo = self:getAcVo()
	if vo and vo.dailyRecharge then
		 vo.dailyRecharge = -1
	end
end
function acShuijinghuikuiVoApi:setDailyRechargeNum(num)
	local vo = self:getAcVo()
	if vo then
		 vo.dailyRecharge = num
	end
end

function acShuijinghuikuiVoApi:updateRecharge(money)
	local vo = self:getAcVo()
	if vo then
		if self:isToday()==false then
			self:setDailyRechargeNum(money)
			self:updateLastTime()
		end
		self:addAllRechargeNum(money)
	end
end
function acShuijinghuikuiVoApi:refreshData()
	local vo = self:getAcVo()
	if vo then
		if G_isToday(vo.lastTime)==false then
			vo.dailyRecharge=0
		end
	end
end
function acShuijinghuikuiVoApi:updateLastTime()
	local vo = self:getAcVo()
	if vo then
		vo.lastTime = G_getWeeTs(base.serverTime)
	end
end

function acShuijinghuikuiVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acShuijinghuikuiVoApi:canReward()
	if self:getDailyRechargeNum()>0 or self:getAllRechargeNum()>0 then
		return true
	end
	return false
end