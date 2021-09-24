acZnkhFiveAnniversaryVoApi = {}

function acZnkhFiveAnniversaryVoApi:getAcVo()
    return activityVoApi:getActivityVo("znkh2018")
end

function acZnkhFiveAnniversaryVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage2.plist")
	spriteController:addTexture("public/activeCommonImage2.png")
end

function acZnkhFiveAnniversaryVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage2.plist")
	spriteController:removeTexture("public/activeCommonImage2.png")
end

function acZnkhFiveAnniversaryVoApi:getTimeStr()
    local vo = self:getAcVo()
    if vo then
        local activeTime = vo.et - 86400 - base.serverTime > 0 and G_formatActiveDate(vo.et - 86400 - base.serverTime) or nil
        if activeTime == nil then
            activeTime = getlocal("serverwarteam_all_end")
        end
        return getlocal("activityCountdown") .. ":" .. activeTime
    end
    return ""
end

function acZnkhFiveAnniversaryVoApi:getRewardTimeStr()
    local vo = self:getAcVo()
    if vo then
        local activeTime = G_formatActiveDate(vo.et - base.serverTime)
        if self:isRewardTime() == false then
            activeTime = getlocal("notYetStr")
        end
        return getlocal("onlinePackage_next_title") .. activeTime
    end
    return ""
end

--是否处于领奖时间
function acZnkhFiveAnniversaryVoApi:isRewardTime()
    local vo = self:getAcVo()
    if vo then
        if base.serverTime > vo.acEt - 86400 and base.serverTime < vo.acEt then
            return true
        end
    end
    return false
end

function acZnkhFiveAnniversaryVoApi:canReward()
    return false
end

--排行奖励
function acZnkhFiveAnniversaryVoApi:getRankReward()
	local vo = self:getAcVo()
	if vo and vo.rankingReward then
		return vo.rankingReward
	end
end

--幸运奖励
function acZnkhFiveAnniversaryVoApi:getLuckyReward()
	local vo = self:getAcVo()
	if vo and vo.luckyReward then
		return vo.luckyReward
	end
end

--获得幸运奖个数
function acZnkhFiveAnniversaryVoApi:getLuckyNum()
	local vo = self:getAcVo()
	if vo and vo.luckyNum then
		return vo.luckyNum
	end
	return 0
end

--获得充值排名个数
function acZnkhFiveAnniversaryVoApi:getRankNum()
	local vo = self:getAcVo()
	if vo and vo.rankingNum then
		return vo.rankingNum
	end
	return 0
end

--获取排行最低充值金额数
function acZnkhFiveAnniversaryVoApi:getRankRecharge()
	local vo = self:getAcVo()
	if vo and vo.rankingRecharge then
		return vo.rankingRecharge
	end
	return 0
end

--获取今日充值金币数
function acZnkhFiveAnniversaryVoApi:getDN()
	local vo = self:getAcVo()
	if vo and vo.dn then
		return vo.dn
	end
	return 0
end

--获取昨日充值金币数
function acZnkhFiveAnniversaryVoApi:getYN()
	local vo = self:getAcVo()
	if vo and vo.yn then
		return vo.yn
	end
	return 0
end

--今日排行数据
function acZnkhFiveAnniversaryVoApi:getDRank()
	if self.drank and self:isRewardTime() == false then
		return self.drank
	end
end

--昨日排行数据
function acZnkhFiveAnniversaryVoApi:getYRank()
	if self.yrank then
		return self.yrank
	end
end

--幸运名单排行数据
function acZnkhFiveAnniversaryVoApi:getLucky()
	if self.lucky then
		return self.lucky
	end
end

function acZnkhFiveAnniversaryVoApi:requestRankData(callback)
	local function socketCallback(fn, data)
		local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
            	if sData.data.znkh2018 then
            		self:updateData(sData.data.znkh2018)
            	end
            	self.drank = nil
            	if sData.data.drank then --今日排行
            		self.drank = sData.data.drank
            	end
            	self.yrank = nil
            	if sData.data.yrank then --昨日排行
            		self.yrank = sData.data.yrank
            	end
            	self.lucky = nil
            	if sData.data.lucky then --幸运名单排行
            		self.lucky = sData.data.lucky
            	end
            	if callback then
            		callback()
            	end
            end
        end
	end
	socketHelper:acZnkh2018GetRank(socketCallback)
end

function acZnkhFiveAnniversaryVoApi:updateData(data)
    if data then
        local vo = self:getAcVo()
        vo:updateData(data)
        activityVoApi:updateShowState(vo)
    end
end

function acZnkhFiveAnniversaryVoApi:clearAll()
	self.drank = nil
	self.yrank = nil
	self.lucky = nil
end