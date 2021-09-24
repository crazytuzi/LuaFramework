acOldReturnVoApi={}

function acOldReturnVoApi:getAcVo()
	return activityVoApi:getActivityVo("twolduserreturn")
end

function acOldReturnVoApi:init(callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			local vo=self:getAcVo()
			vo:updateSpecialData(sData.data.twolduserreturn)
			callback()
		end
	end
	socketHelper:activityOldUserReturnTw("get",nil,onRequestEnd)
end

function acOldReturnVoApi:getUserType()
	local vo=self:getAcVo()
	return vo.userType
end

function acOldReturnVoApi:getUserRewardStatus()
	local vo=self:getAcVo()
	return vo.userRewardGet
end

function acOldReturnVoApi:getServerReturnNum()
	local vo=self:getAcVo()
	return vo.serverReturnNum
end

function acOldReturnVoApi:getServerRewardStatus()
	local vo=self:getAcVo()
	return vo.serverRewardGet
end

function acOldReturnVoApi:getServerRewardCanGet()
	local vo=self:getAcVo()
    local result=math.floor((vo.serverReturnNum-vo.serverRewardGet*vo.cfg.need)/vo.cfg.need)
	return result
end

function acOldReturnVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end

function acOldReturnVoApi:getFeedRewardTime()
	local vo=self:getAcVo()
	return vo.feedTime
end

function acOldReturnVoApi:setFeedRewardTime(time)
	local vo=self:getAcVo()
	vo.feedTime=time
end

function acOldReturnVoApi:setUserRewardGot()
	local vo=self:getAcVo()
	vo.userRewardGet=1
    activityVoApi:updateShowState(vo)
end

function acOldReturnVoApi:setServerRewardGot()
	local vo=self:getAcVo()
	vo.serverRewardGet=math.floor(vo.serverReturnNum/vo.cfg.need)
    activityVoApi:updateShowState(vo)
end


function acOldReturnVoApi:canReward()
    if(playerVoApi:getPlayerLevel()<10)then
        return false
    end
	local vo=self:getAcVo()
	if(vo.cfg==nil or vo.cfg.need==nil)then
		return false
	end
	if(vo.userRewardGet~=1 or self:getServerRewardCanGet()>0)then
		return true
	else
		return false
	end
end
