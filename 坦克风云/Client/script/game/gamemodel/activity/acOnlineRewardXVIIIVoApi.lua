acOnlineRewardXVIIIVoApi={}

function acOnlineRewardXVIIIVoApi:getAcVo()
	return activityVoApi:getActivityVo("online2018")
end


function acOnlineRewardXVIIIVoApi:updateShow()
	local vo=self:getAcVo()
    activityVoApi:updateShowState(vo)
end

function acOnlineRewardXVIIIVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end

function acOnlineRewardXVIIIVoApi:getTimer( )--倒计时 需要时时显示
	local vo=self:getAcVo()
	local str=""
	if vo then
		str=getlocal("activityCountdown")..":"..G_formatActiveDate(vo.et - base.serverTime)
	end
	return str
end

function acOnlineRewardXVIIIVoApi:getRewardCfg()
	local vo  = self:getAcVo()
	if vo and vo.rewardCfg then
		return vo.rewardCfg
	end 
	return {}
end

function acOnlineRewardXVIIIVoApi:getNeedTimeByID(id)
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
function acOnlineRewardXVIIIVoApi:getRewardByID(id)
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

function acOnlineRewardXVIIIVoApi:checkIfCanRewardById(id)
	local onlineTime = self:getOnlineTime()
	local needTime = self:getNeedTimeByID(id)
	-- print("onlineTime=====needTime=====>>>>",onlineTime,needTime)
	if onlineTime>=needTime then
		return true
	end

	return false
end

function acOnlineRewardXVIIIVoApi:checkIfHadRewardById(id)
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
function acOnlineRewardXVIIIVoApi:getOnlineTime()
	local vo = self:getAcVo()
	if vo and vo.acOnlineTime then
		return vo.acOnlineTime 
	end
	return 0
end

function acOnlineRewardXVIIIVoApi:getHadReward()
	local vo = self:getAcVo()
	if vo and vo.hadReward then
		return vo.hadReward
	end
	return {}
end
function acOnlineRewardXVIIIVoApi:addHadRewardByID(id)

	local vo = self:getAcVo()
	if vo then
		if vo.hadReward ==nil then
			vo.hadReward = {}
		end
		if id ~= vo.cfgNum then
			vo.hadReward[id]={1,base.serverTime}
		else
			self:refreshLastAward()
		end
	end

end

function acOnlineRewardXVIIIVoApi:refreshLastAward( )
	local vo = self:getAcVo()
	vo.refreshLastAward = true
end

function acOnlineRewardXVIIIVoApi:getOTime( )
	local vo = self:getAcVo()
	if vo and vo.oldLastAwardT then
		return vo.oldLastAwardT
	end
	return 7200
end
function acOnlineRewardXVIIIVoApi:refreshLastAwardTime( )
	local vo = self:getAcVo()
	if vo then
		vo.rewardCfg[vo.cfgNum].t = 7200
	end
end
function acOnlineRewardXVIIIVoApi:refreshHadReward()
	local vo = self:getAcVo()
	if vo then
		vo.hadReward = {}
		vo.rewardCfg[vo.cfgNum].t = 7200
	end
end

function acOnlineRewardXVIIIVoApi:getRefreshLastAwardType()
	local vo = self:getAcVo()
	return vo.refreshLastAward
end

function acOnlineRewardXVIIIVoApi:addOnlineTimeAfterTick()
	if newGuidMgr:isNewGuiding() == true then
		do return end
	end
    local vo = self:getAcVo()
    if vo then
    	local zoneId=tostring(base.curZoneID)
	    local gameUid=tostring(playerVoApi:getUid())
	    local key = G_local_acOnlineReward2018..zoneId..gameUid
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

	    if vo.hadReward and vo.cfgNum > 0 and vo.hadReward[vo.cfgNum] and vo.hadReward[vo.cfgNum][2] and vo.hadReward[vo.cfgNum][2] > 0 then
	    		vo.hadReward[vo.cfgNum][1] = nil
	    		vo.hadReward[vo.cfgNum][2] = 0
	    		if vo.cfgNum and vo.rewardCfg[vo.cfgNum] and vo.rewardCfg[vo.cfgNum].t == 7200 then
	    			vo.rewardCfg[vo.cfgNum].t = vo.rewardCfg[vo.cfgNum].t + 3600
	    		end
	    end

	    vo:setLastAddTime(base.serverTime)

	    if vo.refreshLastAward then--刷新最后一个奖励
	    	vo.refreshLastAward = false
	    	local valueT = Split(settingsValue,",")
	    	if tonumber(valueT[1]) >= self:getNeedTimeByID(vo.cfgNum) then
		    	local t = valueT[1] - (self:getNeedTimeByID(vo.cfgNum) - self:getNeedTimeByID(vo.cfgNum - 1))
		    	vo.acOnlineTime = t
	    		CCUserDefault:sharedUserDefault():setStringForKey(key,t..","..G_getWeeTs(base.serverTime))
			    CCUserDefault:sharedUserDefault():flush()

			    if vo.cfgNum and vo.rewardCfg[vo.cfgNum] and vo.rewardCfg[vo.cfgNum].t == 7200 then
	    			vo.rewardCfg[vo.cfgNum].t = vo.rewardCfg[vo.cfgNum].t + 3600
	    		end

			    if vo.hadReward and vo.cfgNum > 0 and vo.hadReward[vo.cfgNum] and vo.hadReward[vo.cfgNum][2] and vo.hadReward[vo.cfgNum][2] > 0 then
			    	vo.hadReward[vo.cfgNum][1] = nil
		    		vo.hadReward[vo.cfgNum][2] = 0
			    end
			end
	    end
    end

end

-- 增加用户的在线时间(num 增加额度)
function acOnlineRewardXVIIIVoApi:addOnlineTime(num)

    local zoneId=tostring(base.curZoneID)
    local gameUid=tostring(playerVoApi:getUid())
    local key = G_local_acOnlineReward2018..zoneId..gameUid
    local vo = self:getAcVo()
    local t = vo.acOnlineTime
    -- print("t 1=====>>>>>",t,num)
    if t ~= -1 then
        t = t + num
    else
        local settingsValue = CCUserDefault:sharedUserDefault():getStringForKey(key)
        if settingsValue ~= nil and settingsValue ~= "" then
        	local valueT = Split(settingsValue,",")
        	local addValueT = valueT[1]
        	-- print("addValueT====>>>",addValueT)
        	if addValueT ~= nil then
	           t = tonumber(addValueT) + num
	        else
	            t = num
	        end
        end
    end
    -- print("t 2=====>>>>>",t)
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
    -- print("setStringForKey ========== i n    addOnlineTime",t)
    CCUserDefault:sharedUserDefault():setStringForKey(key,t..","..G_getWeeTs(base.serverTime))
    CCUserDefault:sharedUserDefault():flush()
end

function acOnlineRewardXVIIIVoApi:refreshOnlineTime()
    local zoneId=tostring(base.curZoneID)
    local gameUid=tostring(playerVoApi:getUid())
    local key = G_local_acOnlineReward2018..zoneId..gameUid
    CCUserDefault:sharedUserDefault():setStringForKey(key,"0"..","..G_getWeeTs(base.serverTime))
    CCUserDefault:sharedUserDefault():flush()
end

function acOnlineRewardXVIIIVoApi:updateLastTime()
	local vo = self:getAcVo()
	if vo then
		vo.lastTime = G_getWeeTs(base.serverTime)
	end
end

function acOnlineRewardXVIIIVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acOnlineRewardXVIIIVoApi:canReward()
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