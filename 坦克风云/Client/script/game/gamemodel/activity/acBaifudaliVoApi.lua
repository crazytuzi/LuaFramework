acBaifudaliVoApi={}

function acBaifudaliVoApi:canReward( ... )
	return false
end
function acBaifudaliVoApi:getAcVo()
	return activityVoApi:getActivityVo("baifudali")
end

function acBaifudaliVoApi:getDailyRewardCfg()
	local vo  = self:getAcVo()
	if vo and vo.daily then
		return vo.daily
	end
	return {}
end

function acBaifudaliVoApi:getGoldAction()
	local vo = self:getAcVo()
	if vo and vo.goldAction then
		return vo.goldAction
	end
	return 0 
end

function  acBaifudaliVoApi:getAddGold(  )
	local vo = self:getAcVo()
	if vo and vo.addGold then
		return vo.addGold
	end
	return 0
end

function acBaifudaliVoApi:updateAddGold(money)
	local vo  = self:getAcVo()
	if vo then
		if vo.addGold ==nil then
			vo.addGold = 0 
		end
		vo.addGold =vo.addGold + money
	end
end

function acBaifudaliVoApi:getIsRecGold(  )
	local vo = self:getAcVo()
	if vo then
		return vo.isRecGold
	end
	return 0
end

function  acBaifudaliVoApi:getLevelLimit( )
	local vo = self.getAcVo()
	if vo and vo.levelLimit then
		return vo.levelLimit
	end
	return 0
end

function acBaifudaliVoApi:getRepairVate( )
	local vo = self.getAcVo()
	if vo and vo.repairVate then
		return vo.repairVate
	end
	return 0 
end

function acBaifudaliVoApi:getGoldReward( )
	local vo = self.getAcVo()
	if vo and vo.goldReward then
		return vo.goldReward
	end	
	return 0 
end

function acBaifudaliVoApi:getVersion( )
	local vo = self.getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1
end

function acBaifudaliVoApi:updateIsRecGold()
	local vo = self:getAcVo()
	if vo then
		vo.isRecGold=1
	end
end

function acBaifudaliVoApi:updateLastTime()
	local vo = self:getAcVo()
	if vo then
		vo.time = G_getWeeTs(base.serverTime)
	end
end

function acBaifudaliVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.time then
		isToday=G_isToday(vo.time)
	end
	return isToday
end

function acBaifudaliVoApi:checkIsCanReward()
	local isfree=false
	local playerLV = playerVoApi:getPlayerLevel()
	local levelLimit = self:getLevelLimit()						--是否是第一次免费
	if self:isToday()==false and playerLV>=levelLimit then
		isfree=true
	end
	return isfree
end
function acBaifudaliVoApi:checkIsCanRecGold()
	local hadRechargeNum = self:getAddGold()
	local goldcondition = self:getGoldAction()
	if hadRechargeNum>=goldcondition and self:getIsRecGold()==0 then
		return true
	end
	return false
end
function acBaifudaliVoApi:canReward()
	if self:checkIsCanReward()==true or self:checkIsCanRecGold() then
		return true
	end
	return false
end