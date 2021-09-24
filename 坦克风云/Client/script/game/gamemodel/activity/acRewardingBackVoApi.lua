acRewardingBackVoApi = {

}

function acRewardingBackVoApi:clearAll()

end

function acRewardingBackVoApi:getAcVo()
	return activityVoApi:getActivityVo("rewardingBack")
end

function acRewardingBackVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acRewardingBackVoApi:updateShow()
    local vo=self:getAcVo()
    activityVoApi:updateShowState(vo)
end
--金币倍率
function acRewardingBackVoApi:getGemsRate()
	local vo=self:getAcVo()
	if vo~=nil and vo.rewardCfg~=nil and vo.rewardCfg["u"]~=nil and vo.rewardCfg["u"][1] and vo.rewardCfg["u"][1]["gems"]~=nil then
		return vo.rewardCfg["u"][1]["gems"]
	end
	return 0
end
--水晶倍率
function acRewardingBackVoApi:getGoldsRate()
	local vo=self:getAcVo()
	if vo~=nil and vo.rewardCfg~=nil and vo.rewardCfg["u"]~=nil and vo.rewardCfg["u"][2]~=nil and vo.rewardCfg["u"][2]["gold"]~=nil then
		return vo.rewardCfg["u"][2]["gold"]
	end
	return 0
end
function acRewardingBackVoApi:canReward()
	if self:getRechargeGolds()~=nil and self:getRechargeGolds()>0 then
		return true
	end
	return false
end
function acRewardingBackVoApi:getRewardCfg()
	local vo=self:getAcVo()
	if vo~=nil and vo.rewardCfg~=nil and vo.rewardCfg["u"]~=nil then
		return vo.rewardCfg["u"]
	end
	return {}
end


function acRewardingBackVoApi:getRechargeGolds()
	local vo=self:getAcVo()
	if vo~=nil and vo.rechargeGolds~=nil then
		return vo.rechargeGolds
	end
	return 0
end

function acRewardingBackVoApi:updateRechargeGolds(count)
    print(count)
	local vo=self:getAcVo()
	if vo~=nil and vo.rechargeGolds~=nil then
		vo.rechargeGolds = vo.rechargeGolds+count
         print("add",count)
		activityVoApi:updateShowState(vo)
	end
end

function acRewardingBackVoApi:afterGotReward()
	local vo=self:getAcVo()
	if vo~=nil and vo.rechargeGolds~=nil then
		vo.rechargeGolds = 0
		activityVoApi:updateShowState(vo)
	end
end
