acXuyuanluVoApi={}

function acXuyuanluVoApi:getAcVo()
	return activityVoApi:getActivityVo("xuyuanlu")
end

function acXuyuanluVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end
function acXuyuanluVoApi:updateShow()
    local vo=self:getAcVo()
    activityVoApi:updateShowState(vo)
end

function acXuyuanluVoApi:getAcVersion()
	local vo = self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return nil
end

function acXuyuanluVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end

function acXuyuanluVoApi:getGoldTimesCfg()
	local vo = self:getAcVo()
	if vo and vo.goldTimes then
		return vo.goldTimes
	end
	return {}
end
function acXuyuanluVoApi:getGoldTimesToday()
	local timesCfg = self:getGoldTimesCfg()
	local vo = self:getAcVo()
	if vo and timesCfg then
		local day = math.floor((G_getWeeTs(base.serverTime) - G_getWeeTs(vo.st))/86400) + 1 -- 当前是活动的第几天
		if timesCfg[day] then
			return timesCfg[day]
		end
	end
	return 0
end

function acXuyuanluVoApi:getMaxGoldWishTimes()
	local timesCfg = self:getGoldTimesCfg()
	if timesCfg then
		return timesCfg[SizeOfTable(timesCfg)]
	end
	return 0
end

function acXuyuanluVoApi:getGoldHadWishTimes()
	local vo = self:getAcVo()
	if vo and vo.goldWishNum then
		return vo.goldWishNum
	end
	return 0
end

function acXuyuanluVoApi:addGoldHadWishTimes()
	local vo = self:getAcVo()
	if vo then
		if vo.goldWishNum == nil then
			vo.goldWishNum =0
		end
		vo.goldWishNum = vo.goldWishNum+1
	end
end

function acXuyuanluVoApi:getTodayLeftGoldWishNum()
	local maxNum = self:getGoldTimesToday()
	local hadGoldWishNum = self:getGoldHadWishTimes()
	if maxNum and hadGoldWishNum then
		if maxNum>0 and maxNum>=hadGoldWishNum then
			return tonumber(maxNum-hadGoldWishNum)
		end
	end
	return 0
end

function acXuyuanluVoApi:getGoldWishReward()
	local vo = self:getAcVo()
	if vo and vo.goldReward then
		return vo.goldReward
	end
	return {}
end

function acXuyuanluVoApi:getGoldCost()
	local hadGoldWish = self:getGoldHadWishTimes()
	local rewardCfg = self:getGoldWishReward()
	if hadGoldWish and rewardCfg and  hadGoldWish<SizeOfTable(rewardCfg) then
		return rewardCfg[hadGoldWish+1][1]
	end
	return 9999999
end


function acXuyuanluVoApi:getGoldCostByID(id)
	local rewardCfg = self:getGoldWishReward()
	if  rewardCfg  then
		for k,v in pairs(rewardCfg) do
			if k == id then
				if v and v[1] then
					return v[1]
				end
			end
		end
	end
	return 0
end
function acXuyuanluVoApi:getCanGetGoldNum()
	local hadGoldWish = self:getGoldHadWishTimes()
	local rewardCfg = self:getGoldWishReward()
	if hadGoldWish and rewardCfg and hadGoldWish<SizeOfTable(rewardCfg) then
		return rewardCfg[hadGoldWish+1][2][1],rewardCfg[hadGoldWish+1][2][2]
	end
	return 0,0
end

function acXuyuanluVoApi:getPropTaskCfg()
	local vo = self:getAcVo()
	if vo and vo.resourceTask then
		return vo.resourceTask
	end
	return {}
end

function acXuyuanluVoApi:getPropTaskInfo()
	local vo = self:getAcVo()
	if vo and vo.propTask then
		return vo.propTask
	end
	return {}
end
function acXuyuanluVoApi:getNowRound()
	local propTaskInfo= self:getPropTaskInfo()
	if propTaskInfo and propTaskInfo[2] then
		return propTaskInfo[2]
	end
    return 1
end

function acXuyuanluVoApi:getPropWishNum()
	local vo = self:getAcVo()
	if vo and vo.propWishNum then
		return vo.propWishNum
	end
	return 0
end


function acXuyuanluVoApi:CheckTaskIsCompleteByID(id)
	local taskCfg = self:getPropTaskCfg()
	local round = self:getNowRound()
	local needCfg = taskCfg[round]
	local propTaskInfo= self:getPropTaskInfo()
	if propTaskInfo and propTaskInfo[1] and propTaskInfo[1][id] then
		if propTaskInfo[1][id]>=needCfg[id] then
			return true
		end	
	end
	return false
end
function acXuyuanluVoApi:getConditionByID(id)
	local taskCfg = self:getPropTaskCfg()
	local round = self:getNowRound()
	local needCfg = taskCfg[round]
	local propTaskInfo= self:getPropTaskInfo()
	local state=0
	local need=0
	if propTaskInfo and propTaskInfo[1] and propTaskInfo[1][id] then
		state=propTaskInfo[1][id]
	end
	if needCfg and needCfg[id] then
		need = needCfg[id]
	end
	return state,need
end

function acXuyuanluVoApi:setPropWishNum(num)
	local vo = self:getAcVo()
	if vo then
		vo.propWishNum = num
	end
end

function acXuyuanluVoApi:refreshPropData()
	local vo = self:getAcVo()
	if vo then
		vo.propTask = {{0,0,0},1,{0,0,0}}
		self:updateLastTime()
	end
end


function acXuyuanluVoApi:getChatGoodsCfg()
	local vo = self:getAcVo()
	if vo and vo.chatGoods then
		return vo.chatGoods
	end
	return {}
end
function acXuyuanluVoApi:checkIsChatByID(pid)
	local goodsCfg = self:getChatGoodsCfg()
	if goodsCfg then
		for k,v in pairs(goodsCfg) do
			if v and v == pid then
				return true
			end
		end
	end
	return false
end

function acXuyuanluVoApi:getSpeakVate()
	local vo = self:getAcVo()
	if vo and vo.speakVate then
		return vo.speakVate/100
	end
	return {}
end

function acXuyuanluVoApi:checkIsChat()
	local goldWishRewardCfg = self:getGoldWishReward()
	local hadGoldWishNum = acXuyuanluVoApi:getGoldHadWishTimes()
	if goldWishRewardCfg and hadGoldWishNum and goldWishRewardCfg[hadGoldWishNum+1] and goldWishRewardCfg[hadGoldWishNum+1][3]>0 then
		return true
	end
	return false
end
function acXuyuanluVoApi:updateLastTime()
	local vo = self:getAcVo()
	if vo then
		vo.lastTime = G_getWeeTs(base.serverTime)
	end
end



function acXuyuanluVoApi:setGoldHistory(history)
	local vo = self:getAcVo()
	if vo then
		if history then
			vo.goldHistory = history
		end
	end
end
function acXuyuanluVoApi:getGoldHistory()
	local vo = self:getAcVo()
	if vo and vo.goldHistory then
		return vo.goldHistory
	end
	return {}
end

function acXuyuanluVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acXuyuanluVoApi:canReward()
	if self:getPropWishNum()>=1 or (self:getTodayLeftGoldWishNum()>=1 and playerVoApi:getGems()>=acXuyuanluVoApi:getGoldCost()) then
		return true
	end
	return false
end