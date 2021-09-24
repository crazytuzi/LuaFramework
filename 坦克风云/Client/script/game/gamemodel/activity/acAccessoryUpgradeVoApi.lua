acAccessoryUpgradeVoApi={}

function acAccessoryUpgradeVoApi:getAcVo()
	return activityVoApi:getActivityVo("accessoryEvolution")
end

function acAccessoryUpgradeVoApi:getVersion( )
	local vo = self:getAcVo()
	if vo and vo.version then
		self.version =vo.version
	end
	return self.version
end
function acAccessoryUpgradeVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end

function acAccessoryUpgradeVoApi:getTodayByTime()
	local vo=self:getAcVo()
	if(vo.lastByTimestamp<G_getWeeTs(base.serverTime))then
		vo.todayBy=0
	end
	return vo.todayBy
end

function acAccessoryUpgradeVoApi:buyMoney(callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			self:updateLastTime()
			local vo=self:getAcVo()
			vo.todayBy=vo.todayBy+1
			vo.lastByTimestamp=base.serverTime
			local award=FormatItem(sData.data.reward) or {}
			for k,v in pairs(award) do
				G_addPlayerAward(v.type,v.key,v.id,v.num)
			end
			local gems=tonumber(sData.data.gems)
			playerVoApi:setGems(gems)
			callback()
		end
	end
	socketHelper:activeAccessoryUpgradeBuy(onRequestEnd)
end

function acAccessoryUpgradeVoApi:canReward()
	return false
end

function acAccessoryUpgradeVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	-- print("in isToday----->",isToday)
	return isToday
end

function acAccessoryUpgradeVoApi:updateLastTime()
	local vo = self:getAcVo()
	if vo then
		vo.lastTime = base.serverTime
	end
end