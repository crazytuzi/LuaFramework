acOnlineRewardVoApi={}

function acOnlineRewardVoApi:getAcVo()
	return activityVoApi:getActivityVo("onlineReward")
end


function acOnlineRewardVoApi:updateShow()
	local vo=self:getAcVo()
    activityVoApi:updateShowState(vo)
end

function acOnlineRewardVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end



function acOnlineRewardVoApi:getRewardCfg()
	local vo  = self:getAcVo()
	if vo and vo.rewardCfg then
		return vo.rewardCfg
	end 
	return {}
end

function acOnlineRewardVoApi:getNeedTimeByID(id)
	local cfg = self:getRewardCfg()
	if cfg then
		for k,v in pairs(cfg) do
			if k and k==id and v and v.t then
				return tonumber(v.t)
			end
		end
	end
	return 0
end
function acOnlineRewardVoApi:getRewardByID(id)
	local cfg = self:getRewardCfg()
	if cfg then
		for k,v in pairs(cfg) do
			if k and k==id and v and v.award then
				return v.award
			end
		end
	end
	return {}
end

function acOnlineRewardVoApi:checkIfCanRewardById(id)
	local onlineTime = self:getOnlineTime()
	local needTime = self:getNeedTimeByID(id)
	if onlineTime>=needTime then
		return true
	end

	return false
end

function acOnlineRewardVoApi:checkIfHadRewardById(id)
	local hadRewardTb = self:getHadReward()
	if hadRewardTb then
		for k,v in pairs(hadRewardTb) do
			if k and k==id  and v[1] and v[1]== 1 then
				return true
			end
		end
	end
	return false
end
function acOnlineRewardVoApi:getOnlineTime()
	local vo = self:getAcVo()
	if vo and vo.acOnlineTime then
		return vo.acOnlineTime 
	end
	return 0
end

function acOnlineRewardVoApi:getHadReward()
	local vo = self:getAcVo()
	if vo and vo.hadReward then
		return vo.hadReward
	end
	return {}
end
function acOnlineRewardVoApi:addHadRewardByID(id)

	local vo = self:getAcVo()
	if vo then
		if vo.hadReward ==nil then
			vo.hadReward = {}
		end
		vo.hadReward[id]={1,base.serverTime}
	end

end
function acOnlineRewardVoApi:refreshHadReward()
	local vo = self:getAcVo()
	if vo then
		vo.hadReward = {}
	end
end

function acOnlineRewardVoApi:addOnlineTimeAfterTick()
	if newGuidMgr:isNewGuiding() == true then
		do return end
	end
    local vo = self:getAcVo()
    if vo then
    	local zoneId=tostring(base.curZoneID)
	    local gameUid=tostring(playerVoApi:getUid())
	    local key = G_local_acOnlineReward..zoneId..gameUid
    	local settingsValue = CCUserDefault:sharedUserDefault():getStringForKey(key)
    	if settingsValue and settingsValue~="" then
        	local valueT = Split(settingsValue,",")
        	if valueT then
	        	local time = valueT[2]
	        	if time and G_isToday(time)==false then
	        		self:refreshOnlineTime()
	        		self:refreshHadReward()
	        		self:updateLastTime()
	        		vo.acOnlineTime=0
	        	end
	        end
        end
        
    	local lastAddTime = vo:getLastAddTime()
	    if lastAddTime ~= nil and lastAddTime > 0 then
	        local addTime = base.serverTime - lastAddTime
	        if addTime > -10 and addTime < 10 then
	            self:addOnlineTime(addTime) 
	        end
	    end
	    vo:setLastAddTime(base.serverTime)
    end

    
end

-- 增加用户的在线时间(num 增加额度)
function acOnlineRewardVoApi:addOnlineTime(num)

    local zoneId=tostring(base.curZoneID)
    local gameUid=tostring(playerVoApi:getUid())
    local key = G_local_acOnlineReward..zoneId..gameUid
    local vo = self:getAcVo()
    local t = vo.acOnlineTime

    if t ~= -1 then
        t = t + num
    else
        local settingsValue = CCUserDefault:sharedUserDefault():getStringForKey(key)
        if settingsValue ~= nil and settingsValue ~= "" then
        	local valueT = Split(settingsValue,",")
        	local addValueT = valueT[1]
        	if addValueT ~= nil then
	           t = tonumber(addValueT) + num
	        else
	            t = num
	        end
        end
    end

    local cfg = self:getRewardCfg()
	if cfg then
		for k,v in pairs(cfg) do
			if k and v and v.t and t>=v.t then
				if self:checkIfCanRewardById(k)==true and  self:checkIfHadRewardById(k) == false then
					t=v.t
				end
			end
		end
	end

    if t < 0 then
        t = 0
    end
    vo:updateOnlineTime(t)
    if self:canReward() == true then
    	self:updateShow()
    end

    CCUserDefault:sharedUserDefault():setStringForKey(key,t..","..G_getWeeTs(base.serverTime))
    CCUserDefault:sharedUserDefault():flush()
end

function acOnlineRewardVoApi:refreshOnlineTime()
    local zoneId=tostring(base.curZoneID)
    local gameUid=tostring(playerVoApi:getUid())
    local key = G_local_acOnlineReward..zoneId..gameUid
    CCUserDefault:sharedUserDefault():setStringForKey(key,"0"..","..G_getWeeTs(base.serverTime))
    CCUserDefault:sharedUserDefault():flush()
end

function acOnlineRewardVoApi:updateLastTime()
	local vo = self:getAcVo()
	if vo then
		vo.lastTime = G_getWeeTs(base.serverTime)
	end
end

function acOnlineRewardVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acOnlineRewardVoApi:canReward()
	local cfg = self:getRewardCfg()
	if cfg then
		for k,v in pairs(cfg) do
			if self:checkIfCanRewardById(k) and self:checkIfHadRewardById(k)==false then
				return true
			end
		end
	end
	return false
end