acReturnVoApi={}

function acReturnVoApi:getAcVo()
	return activityVoApi:getActivityVo("oldUserReturn")
end

function acReturnVoApi:init(callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			local vo=self:getAcVo()
			vo:updateSpecialData(sData.data.oldUserReturn)
			callback()
		end
	end
	socketHelper:activeReturnInit(onRequestEnd)
end

function acReturnVoApi:getUserType()
	local vo=self:getAcVo()
	return vo.userType
end

function acReturnVoApi:getUserRewardStatus()
	local vo=self:getAcVo()
	return vo.userRewardGet
end

function acReturnVoApi:getServerReturnNum()
	local vo=self:getAcVo()
	return vo.serverReturnNum
end

function acReturnVoApi:getServerRewardStatus()
	local vo=self:getAcVo()
	return vo.serverRewardGet
end

function acReturnVoApi:getServerRewardCanGet()
	local vo=self:getAcVo()
    local result=math.floor((vo.serverReturnNum-vo.serverRewardGet*activityCfg.oldUserReturn.serverreward.need)/activityCfg.oldUserReturn.serverreward.need)
	return result
end

function acReturnVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end

function acReturnVoApi:setUserRewardGot()
	local vo=self:getAcVo()
	vo.userRewardGet=1
    activityVoApi:updateShowState(vo)
end

function acReturnVoApi:setServerRewardGot()
	local vo=self:getAcVo()
	vo.serverRewardGet=math.floor(vo.serverReturnNum/activityCfg.oldUserReturn.serverreward.need)
    activityVoApi:updateShowState(vo)
end


function acReturnVoApi:canReward()
    if(playerVoApi:getPlayerLevel()<10)then
        return false
    end
	local vo=self:getAcVo()
	if(vo.userRewardGet~=1 or self:getServerRewardCanGet()>0)then
		return true
	else
		return false
	end
end
