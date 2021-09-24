acLuckUpVoApi = {}

function acLuckUpVoApi:getAcVo()
	return activityVoApi:getActivityVo("luckUp")
end

function acLuckUpVoApi:getAcCfg()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.otherData
	end
	return nil
end

function acLuckUpVoApi:getAddTroops()
	local cfg = self:getAcCfg()
	if cfg ~= nil and cfg.troopsup and cfg.troopsup.upRate then
		return tonumber(cfg.troopsup.upRate) *  100
	end
	return 0
end

function acLuckUpVoApi:getAddDrop()
	local cfg = self:getAcCfg()
	if cfg ~= nil and cfg.attackIsland and cfg.attackIsland.propRate then
		return tonumber(cfg.attackIsland.propRate) *  100
	end
	return 0
end

function acLuckUpVoApi:getAddExp()
	local cfg = self:getAcCfg()
	if cfg ~= nil and cfg.attackChallenge and cfg.attackChallenge.exp then
		return tonumber(cfg.attackChallenge.exp) *  100
	end
	return 0
end

function acLuckUpVoApi:canReward()
	return false
end