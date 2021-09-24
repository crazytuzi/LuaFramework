acFundsRecruitVoApi = {

}

function acFundsRecruitVoApi:clearAll()

end

function acFundsRecruitVoApi:getAcVo()
	return activityVoApi:getActivityVo("fundsRecruit")
end

function acFundsRecruitVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	vo:updateFundsRecruitData(data)
	activityVoApi:updateShowState(vo)
end

function acFundsRecruitVoApi:updateShow()
    local vo=self:getAcVo()
    activityVoApi:updateShowState(vo)
end
--在线时间配置 单位：分钟
function acFundsRecruitVoApi:getOnlineTimeCfg()
	local vo=self:getAcVo()
    if vo.rewardCfg~=nil then
        return vo.rewardCfg[1][2]/60
    end
    return 60
end
--军团捐献次数配置
function acFundsRecruitVoApi:getAllianceDonateNumCfg()
	local vo=self:getAcVo()
    if vo.rewardCfg~=nil then
        return vo.rewardCfg[2][2]
    end
    return 10
end
--金币捐献次数配置
function acFundsRecruitVoApi:getGoldsDonateNumCfg()
	local vo=self:getAcVo()
    if vo.rewardCfg~=nil then
        return vo.rewardCfg[3][2]
    end
    return 5
end

--军团资金奖励
function acFundsRecruitVoApi:getAlliancePointRewardCfg(index)
	local vo=self:getAcVo()
    if vo.rewardCfg~=nil then
        return vo.rewardCfg[index][1]["point"]
    end
    return {}
end
--加入军团在线时间 单位：分钟
function acFundsRecruitVoApi:getAllianceOnline()
	local vo=self:getAcVo()
	if self:isGotOnlineRewards()==true then
		return self:getOnlineTimeCfg()
	end
	if vo.longinSt~=nil then
		if base.serverTime-vo.longinSt<0 then
			return 0
		end
		if (base.serverTime-vo.longinSt)/60>=self:getOnlineTimeCfg() then
			return self:getOnlineTimeCfg()
		else
			return math.floor((base.serverTime-vo.longinSt)/60)
		end
	end
	return 0
end
--当天每日在线奖励是否已领取
function acFundsRecruitVoApi:isGotOnlineRewards( ... )
	local vo=self:getAcVo()
	if vo.ls and vo.ls["lg"][2] and G_getWeeTs(base.serverTime)<=vo.ls["lg"][2] then
		return true
	end
	return false

end
--当天军团捐献奖励是否已领取
function acFundsRecruitVoApi:isGotResourceDonateRewards( ... )
	local vo=self:getAcVo()
	if vo.ls and vo.ls["gd"][2] and G_getWeeTs(base.serverTime)<=vo.ls["gd"][2] then
		return true
	end
	return false

end
--当天金币奖励是否已领取
function acFundsRecruitVoApi:isGotGoldDonateRewards( ... )
	local vo=self:getAcVo()
	if vo.ls and vo.ls["gm"][2] and G_getWeeTs(base.serverTime)<=vo.ls["gm"][2] then
		return true
	end
	return false

end
--是否可领取每日在线奖励
function  acFundsRecruitVoApi:iscanGetOnlineRewards( ... )
	if self:isGotOnlineRewards()==false and self:getAllianceOnline()>=self:getOnlineTimeCfg() then
		return true
	else
		return false
	end
end
--资源捐献次数
function acFundsRecruitVoApi:getResourceDonateCount(...)
	local vo=self:getAcVo()
	if self:isGotResourceDonateRewards()==true then
		return self:getAllianceDonateNumCfg()
	end

	if vo.allianceDonateCount~=nil then
		if vo.allianceDonateCount>=self:getAllianceDonateNumCfg() then
			return self:getAllianceDonateNumCfg()
		end
    	return vo.allianceDonateCount
    end
    return 0
end
--是否可领取资源捐献奖励
function acFundsRecruitVoApi:iscanGetResourceDonateRewards( ... )
	if self:isGotResourceDonateRewards()==false and self:getResourceDonateCount()>=self:getAllianceDonateNumCfg() then
		return true
	else
		return false
	end
end
--金币捐献次数
function acFundsRecruitVoApi:getGoldDonateCount(...)
	local vo=self:getAcVo()
	if self:isGotGoldDonateRewards()==true then
		return self:getGoldsDonateNumCfg()
	end
	if vo.goldDonateCount~=nil then
		if vo.goldDonateCount>=self:getGoldsDonateNumCfg() then
			return self:getGoldsDonateNumCfg()
		end
    	return vo.goldDonateCount
    end
    return 0
end
--是否可领取金币捐献奖励
function acFundsRecruitVoApi:iscanGetGoldDonateRewards( ... )
	if self:isGotGoldDonateRewards()==false and self:getGoldDonateCount()>=self:getGoldsDonateNumCfg() then
		return true
	else
		return false
	end
end

function acFundsRecruitVoApi:canReward()
	if allianceVoApi:isHasAlliance()==false then
		return false
	end
	if self:iscanGetOnlineRewards()==false and self:iscanGetResourceDonateRewards()==false and self:iscanGetGoldDonateRewards()==false then
		return false
	end
	return true
end


function acFundsRecruitVoApi:updateAllianceDonateCount(count)
	local vo=self:getAcVo()
	if vo.allianceDonateCount~=nil then
		vo.allianceDonateCount = vo.allianceDonateCount+count
		if vo.allianceDonateCount>=self:getAllianceDonateNumCfg() then
			vo.allianceDonateCount=self:getAllianceDonateNumCfg()
		end
		activityVoApi:updateShowState(vo)
	end
end
function acFundsRecruitVoApi:updateGoldDonateCount(count)
	local vo=self:getAcVo()
	if vo.goldDonateCount~=nil then
		vo.goldDonateCount = vo.goldDonateCount+count
		if vo.goldDonateCount>=self:getGoldsDonateNumCfg() then
			vo.goldDonateCount=self:getGoldsDonateNumCfg()
		end
		activityVoApi:updateShowState(vo)
	end
end


