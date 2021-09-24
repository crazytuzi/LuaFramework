acKfczVoApi = {}

function acKfczVoApi:getAcVo()
    return activityVoApi:getActivityVo("kfcz")
end

function acKfczVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage2.plist")
	spriteController:addTexture("public/activeCommonImage2.png")
end

function acKfczVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage2.plist")
	spriteController:removeTexture("public/activeCommonImage2.png")
end

function acKfczVoApi:getVersion()
	local vo = self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1
end

function acKfczVoApi:getTimeStr()
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

function acKfczVoApi:getRewardTimeStr()
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
function acKfczVoApi:isRewardTime()
    local vo = self:getAcVo()
    if vo then
        if base.serverTime > vo.acEt - 86400 and base.serverTime < vo.acEt then
            return true
        end
    end
    return false
end

function acKfczVoApi:canReward()
    return false
end

--排行奖励
function acKfczVoApi:getRankReward()
	local vo = self:getAcVo()
	if vo and vo.rankingReward then
		return vo.rankingReward
	end
end

--幸运奖励
function acKfczVoApi:getLuckyReward()
	local vo = self:getAcVo()
	if vo and vo.luckyReward then
		return vo.luckyReward
	end
end

--获得幸运奖个数
function acKfczVoApi:getLuckyNum()
	local vo = self:getAcVo()
	if vo and vo.luckyNum then
		return vo.luckyNum
	end
	return 0
end

--获得充值排名个数
function acKfczVoApi:getRankNum()
	local vo = self:getAcVo()
	if vo and vo.rankingNum then
		return vo.rankingNum
	end
	return 0
end

--获取排行最低充值金额数
function acKfczVoApi:getRankRecharge()
	local vo = self:getAcVo()
	if vo and vo.rankingRecharge then
		return vo.rankingRecharge
	end
	return 0
end

--获取上榜奖励
function acKfczVoApi:getListReward()
	local vo = self:getAcVo()
	if vo and vo.listReward then
		return vo.listReward
	end
end

--获取连榜奖励
function acKfczVoApi:getKeepReward()
	local vo = self:getAcVo()
	if vo and vo.keepReward then
		return vo.keepReward
	end
end

--获取今日充值金币数
function acKfczVoApi:getDN()
	local vo = self:getAcVo()
	if vo and vo.dn then
		return vo.dn
	end
	return 0
end

--获取昨日充值金币数
function acKfczVoApi:getYN()
	local vo = self:getAcVo()
	if vo and vo.yn then
		return vo.yn
	end
	return 0
end

--今日排行数据
function acKfczVoApi:getDRank()
	if self.drank and self:isRewardTime() == false then
		return self.drank
	end
end

--昨日排行数据
function acKfczVoApi:getYRank()
	if self.yrank then
		return self.yrank
	end
end

--幸运名单排行数据
function acKfczVoApi:getLucky()
	if self.lucky then
		return self.lucky
	end
end

--连榜排行数据
function acKfczVoApi:getKeep()
	if self.keep then
		return self.keep
	end
end

function acKfczVoApi:requestRankData(callback)
	local function socketCallback(fn, data)
		local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
            	if sData.data.kfcz then
            		self:updateData(sData.data.kfcz)
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
            	self.keep = nil
            	if sData.data.keep then --连榜排行
            		self.keep = sData.data.keep
            	end
            	if callback then
            		callback()
            	end
            end
        end
	end
	socketHelper:acKfczGetRank(socketCallback)
end

function acKfczVoApi:updateData(data)
    if data then
        local vo = self:getAcVo()
        vo:updateData(data)
        activityVoApi:updateShowState(vo)
    end
end

function acKfczVoApi:clearAll()
	self.drank = nil
	self.yrank = nil
	self.lucky = nil
	self.keep  = nil
end